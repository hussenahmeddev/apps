const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const db = admin.firestore();

/**
 * Triggered on new event creation.
 * Broadcasts notification to all enrolled campus users.
 */
exports.onEventCreated = functions.firestore
  .document('events/{eventId}')
  .onCreate(async (snap, context) => {
    const event = snap.data();
    const eventId = context.params.eventId;

    const payload = {
      notification: {
        title: `New Event: ${event.title}`,
        body: `Happening on ${event.location}. Tap to register!`,
      },
      data: {
        type: 'event_update',
        eventId: eventId,
      },
      topic: 'all_users',
    };

    try {
      await admin.messaging().send(payload);
      console.log(`Event notification sent for eventId: ${eventId}`);
    } catch (error) {
      console.error('Error sending event FCM:', error);
    }
  });

/**
 * Triggered on new announcement creation.
 * Broadcasts high-priority push notification to topic 'announcements'.
 */
exports.onAnnouncementCreated = functions.firestore
  .document('announcements/{announcementId}')
  .onCreate(async (snap, context) => {
    const notice = snap.data();
    const isUrgent = notice.priority === 'urgent';

    const payload = {
      notification: {
        title: isUrgent ? `🚨 URGENT: ${notice.title}` : `📢 Campus Announcement: ${notice.title}`,
        body: notice.content.substring(0, 150),
      },
      data: {
        type: 'announcement',
        announcementId: context.params.announcementId,
      },
      topic: 'announcements',
    };

    try {
      await admin.messaging().send(payload);
      console.log(`Announcement notification sent.`);
    } catch (error) {
      console.error('Error sending announcement FCM:', error);
    }
  });

/**
 * Event Registration confirmation.
 * Sends individual push notification to student upon successful registration.
 */
exports.onRegistrationCreated = functions.firestore
  .document('registrations/{registrationId}')
  .onCreate(async (snap, context) => {
    const reg = snap.data();

    // Fetch user fcmToken
    const userDoc = await db.collection('users').doc(reg.userId).get();
    if (!userDoc.exists) return;

    const fcmToken = userDoc.data().fcmToken;
    if (!fcmToken) return;

    const message = {
      token: fcmToken,
      notification: {
        title: 'Registration Confirmed! 🎉',
        body: `You are registered for "${reg.eventTitle}". We look forward to seeing you there!`,
      },
      data: {
        type: 'registration',
        eventId: reg.eventId,
      },
    };

    try {
      await admin.messaging().send(message);
    } catch (error) {
      console.error('Failed to send registration notification:', error);
    }
  });

