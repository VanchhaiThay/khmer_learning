import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddFriendDialog extends StatelessWidget {
  final User currentUser;
  const AddFriendDialog({super.key, required this.currentUser});

  @override
  Widget build(BuildContext context) {
    final uidController = TextEditingController();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add Friend",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: uidController,
              decoration: const InputDecoration(
                labelText: "Friend's UID",
                prefixIcon: Icon(Icons.fingerprint),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    final friendUid = uidController.text.trim();
                    if (friendUid.isEmpty) return;
                    if (friendUid == currentUser.uid) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("You cannot add yourself"),
                        ),
                      );
                      return;
                    }

                    final friendDoc = await FirebaseFirestore.instance
                        .collection('users')
                        .doc(friendUid)
                        .get();

                    if (!friendDoc.exists) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("User UID not found")),
                      );
                      return;
                    }

                    final friendData = friendDoc.data()!;
                    final firstName = friendData['first_name'] ?? '';
                    final lastName = friendData['last_name'] ?? '';

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(currentUser.uid)
                        .collection('friends')
                        .doc(friendUid)
                        .set({
                      'uid': friendUid,
                      'firstName': firstName,
                      'lastName': lastName,
                      'addedAt': FieldValue.serverTimestamp(),
                    });

                    await FirebaseFirestore.instance
                        .collection('users')
                        .doc(friendUid)
                        .collection('friends')
                        .doc(currentUser.uid)
                        .set({
                      'uid': currentUser.uid,
                      'firstName': currentUser.displayName
                              ?.split(' ')
                              .first ??
                          '',
                      'lastName': currentUser.displayName?.split(' ').last ?? '',
                      'addedAt': FieldValue.serverTimestamp(),
                    });

                    final chatIdList = [currentUser.uid, friendUid]..sort();
                    final chatDocId = chatIdList.join('_');
                    final chatDocRef =
                        FirebaseFirestore.instance.collection('chats').doc(chatDocId);
                    if (!(await chatDocRef.get()).exists) {
                      await chatDocRef.set({'users': chatIdList});
                    }

                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Friend added successfully")),
                    );
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
