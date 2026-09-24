/**
 * One-time script to import sample_data/firestore_sample_data.json into
 * Firestore using the Firebase Admin SDK.
 *
 * Usage:
 *   1. npm install firebase-admin
 *   2. Download a service account key from
 *      Firebase Console > Project Settings > Service Accounts
 *      and save it as service-account.json in this folder.
 *   3. node import_sample_data.js
 *
 * NOTE: replace CHEF_UID_PLACEHOLDER / ADMIN_UID_PLACEHOLDER in the JSON
 * with real Firebase Auth UIDs (create the chef/admin accounts first via
 * Firebase Auth console or the in-app registerStaff() flow).
 */
const admin = require('firebase-admin');
const data = require('./firestore_sample_data.json');
const serviceAccount = require('./service-account.json');

admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
const db = admin.firestore();

async function importCollection(collectionName, docs) {
  const batch = db.batch();
  Object.entries(docs).forEach(([docId, docData]) => {
    const ref = db.collection(collectionName).doc(docId);
    batch.set(ref, docData, { merge: true });
  });
  await batch.commit();
  console.log(`Imported ${Object.keys(docs).length} docs into "${collectionName}"`);
}

async function run() {
  for (const [collectionName, docs] of Object.entries(data)) {
    if (collectionName.startsWith('_')) continue; // skip _readme
    await importCollection(collectionName, docs);
  }
  console.log('Sample data import complete.');
  process.exit(0);
}

run().catch((err) => {
  console.error(err);
  process.exit(1);
});
