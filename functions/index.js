const functions = require("firebase-functions");
const { GoogleGenerativeAI } = require("@google/generative-ai");

const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY);

exports.geminiSorgusu = functions.https.onCall(async (data, context) => {
  try {
    // 🛡️ ZIRH: Firebase veriyi nereye saklarsa saklasın, iki ihtimali de kontrol et!
    const prompt = data.prompt || (data.data && data.data.prompt);

    if (!prompt) {
      throw new Error("Sunucuya giden soru boş ulaştı! Gelen paket: " + JSON.stringify(data));
    }

    // 🚀 2026 yılına uygun, emekli olmamış güncel model:
    const model = genAI.getGenerativeModel({ model: "gemini-3.6-flash" });

    const result = await model.generateContent(prompt);
    const response = await result.response;

    return { cevap: response.text() };
  } catch (error) {
    throw new functions.https.HttpsError('internal', 'Gemini Sunucu Hatası: ' + error.message);
  }
});