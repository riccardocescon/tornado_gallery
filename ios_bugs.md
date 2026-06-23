# iOS Bug List

## 1. Public folder rename — not persisted after restart
**Symptom:** Renaming a public folder works visually within the same session. After restarting the app, the original folder remains and the renamed one is also created (duplicate).
**Hypothesis:** The rename does not correctly update the filesystem/PhotoManager metadata, or `IosPublicStorageDatasource` does not invalidate its cache. The UI reflects the in-memory state (`AppBloc`) but on restart it re-reads from disk and finds both folders.

---

## 2. Encryption page — asks to delete the image after saving to a public folder
**Symptom:** When saving an image to a public folder from the encryption page on iOS, the app prompts the user to delete it.
**Hypothesis:** The save flow likely detects the original image in the gallery and tries to remove it (correct behavior on Android), but on iOS the delete permission surfaces as an explicit dialog to the user instead of being silent.

---

## 3. Folder deletion — removed from UI even if permission is denied
**Symptom:** On iOS, if the user tries to delete a folder and denies the permission, the folder (and all images inside it) is still removed from the UI.
**Cause:** The UI updates state before receiving confirmation from the datasource. There is no rollback if the operation fails or is denied.
**Expected fix:** Update the UI only after the datasource confirms success, or roll back state if the operation fails/is denied.
