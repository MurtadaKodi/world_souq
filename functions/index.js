const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

/**
 * 🔔 إشعار عند إنشاء حجز جديد
 */
exports.onNewBooking = onDocumentCreated(
  {
    document: "bookings/{bookingId}",
    region: "us-central1",
  },
  async (event) => {

    const booking = event.data?.data();
    if (!booking) return null;

    const { ownerId, clientId, propertyName, visitTime } = booking;

    // ===== OWNER NOTIFICATION =====
    try {
      const ownerDoc = await db.collection("users").doc(ownerId).get();
      const ownerToken = ownerDoc.data()?.fcmToken;

      if (ownerToken) {
        await admin.messaging().send({
          token: ownerToken,
          notification: {
            title: "📅 حجز جديد",
            body: `🏠 ${propertyName}\n⏰ ${visitTime}`, data: {
              type: "new_booking",
              bookingId: event.params.bookingId,
              screen: "booking_details"
            }
          },
          data: {
            type: "new_booking",
            bookingId: event.params.bookingId,
          },
        });
      }
    } catch (e) {
      console.error("Owner notification error:", e);
    }

    // ===== CLIENT NOTIFICATION =====
    try {
      const clientDoc = await db.collection("users").doc(clientId).get();
      const clientToken = clientDoc.data()?.fcmToken;

      if (clientToken) {
        await admin.messaging().send({
          token: clientToken,
          notification: {
            title: "📥 تم إرسال طلب الحجز",
            body: `${propertyName} • ${visitTime}`,
          },
          data: {
            type: "booking_created",
            bookingId: event.params.bookingId,
          },
        });
      }
    } catch (e) {
      console.error("Client notification error:", e);
    }

    return null;
  }
);

const { onDocumentUpdated } = require("firebase-functions/v2/firestore");
// const admin = require("firebase-admin"); // Already required above

// const db = admin.firestore(); // Already declared above

/**
 * 🔔 إشعار عند تأكيد الحجز
 */
exports.onBookingConfirmed = onDocumentUpdated(
  {
    document: "bookings/{bookingId}",
    region: "us-central1",
  },
  async (event) => {
    const before = event.data?.before.data();
    const after = event.data?.after.data();

    if (!before || !after) return;

    // نتحقق من تغيير الحالة فقط
    if (before.status === after.status) return;

    if (after.status !== "confirmed") return;

    const { clientId, propertyName, visitTime } = after;

    try {
      const userDoc = await db.collection("users").doc(clientId).get();
      const token = userDoc.data()?.fcmToken;

      if (!token) return;

      await admin.messaging().send({
        token,
        notification: {
          title: "✅ تم تأكيد الحجز",
          body: `${propertyName} • ${visitTime}`,
        },
        data: {
          type: "booking_confirmed",
        },
      });
    } catch (e) {
      console.error("Confirm notification error:", e);
    }
  },
);
