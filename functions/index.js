const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");
const qs = require("querystring");

admin.initializeApp();
const db = admin.firestore();

// Thay secret bạn đã nhận được từ VNPAY
const VNP_HASH_SECRET = "LI827NY66IJDKCKUEJ7XK0A3AUF0X2ME";

// Hàm xử lý callback từ VNPAY
exports.vnpayReturn = functions.https.onRequest(async (req, res) => {
  // Debug method và tham số gốc
  console.log("🔥 Method:", req.method);

  // 1. Thu thập params từ GET hoặc POST
  let vnpParams = {};
  if (req.method === "GET") {
    console.log("🔥 Callback params (GET):", req.query);
    vnpParams = { ...req.query };
  } else if (req.method === "POST") {
    const rawBody = req.rawBody ? req.rawBody.toString() : "";
    console.log("🔥 Raw callback body:", rawBody);
    vnpParams = qs.parse(rawBody);
    console.log("🔥 Callback params (POST):", vnpParams);
  } else {
    return res.status(405).send("Method Not Allowed");
  }

  // 2. Lấy giá trị SecureHash và xóa hai field khỏi object
  const vnpSecureHash = vnpParams.vnp_SecureHash;
  const vnpSecureHashType = (
    vnpParams.vnp_SecureHashType || "SHA512"
  ).toString();
  console.log("🔍 vnp_SecureHashType:", vnpSecureHashType);

  delete vnpParams.vnp_SecureHash;
  delete vnpParams.vnp_SecureHashType;

  // 3. Tạo chuỗi signData
  const signData = Object.keys(vnpParams)
    .sort()
    .map((key) => `${key}=${vnpParams[key]}`)
    .join("&");
  console.log("✅ signData:", signData);

  // 4. Chọn thuật toán HMAC dựa trên SecureHashType
  const algorithm = vnpSecureHashType === "SHA256" ? "sha256" : "sha512";
  console.log("✅ Algorithm used:", algorithm);

  // 5. Tính toán checksum
  const hmac = crypto.createHmac(algorithm, VNP_HASH_SECRET);
  const signed = hmac.update(signData, "utf8").digest("hex");
  console.log("✅ Your signed:", signed);
  console.log("✅ VNPay vnp_SecureHash:", vnpSecureHash);

  // 6. So sánh checksum (ignore case)
  if (!vnpSecureHash || signed.toLowerCase() !== vnpSecureHash.toLowerCase()) {
    console.error("‼️ Checksum mismatch");
    return res.status(400).send("Checksum không hợp lệ...");
  }

  // 7. Xử lý kết quả thanh toán
  const responseCode = vnpParams.vnp_ResponseCode;
  const txnRef = vnpParams.vnp_TxnRef;
  const amountVND = parseInt(vnpParams.vnp_Amount, 10) / 100;

  if (responseCode === "00") {
    // Cập nhật Firestore trong transaction
    try {
      const orderRef = db.collection("vnpay_orders").doc(txnRef);
      const orderSnap = await orderRef.get();
      if (!orderSnap.exists) {
        return res.status(404).send("Order không tồn tại");
      }
      const { uid } = orderSnap.data();
      const userRef = db.collection("users").doc(uid);

      await db.runTransaction(async (tx) => {
        const userSnap = await tx.get(userRef);
        const prevCoin = userSnap.data()?.mangaCoin ?? 0;
        const addCoin = Math.floor(amountVND / 1000);
        tx.update(userRef, { mangaCoin: prevCoin + addCoin });
        tx.update(orderRef, { status: "SUCCESS" });
      });

      return res.send("Thanh toán thành công");
    } catch (e) {
      console.error(e);
      return res.status(500).send("Lỗi server khi cập nhật dữ liệu");
    }
  } else {
    // Giao dịch không thành công
    await db
      .collection("vnpay_orders")
      .doc(txnRef)
      .update({ status: "FAILED" });
    return res.send(`Thanh toán thất bại: mã ${responseCode}`);
  }
});
