# Phase 2: Community Module - Testing Guide

## Pre-Testing Setup

### Requirements
- Flutter 3.8.1+
- Android Emulator or Physical Device
- Firebase account configured
- All Phase 1 auth working

### Build & Run
```bash
cd e:\Study\Coding_Projects\Flutter_Projects\Unimate
flutter pub get
flutter run
```

## Testing Scenarios

### Test 1: Community Feed Loading ✅

**Objective:** Verify posts load and display correctly

**Steps:**
1. App starts after login
2. Tap "Community" tab at bottom
3. Observe community feed loads

**Expected Results:**
- [ ] Community Feed screen appears
- [ ] AppBar shows "Community Feed"
- [ ] Posts display in a scrollable list
- [ ] Each post card shows:
  - [ ] Author avatar (circle)
  - [ ] Author name and username
  - [ ] Post creation date
  - [ ] Post title
  - [ ] Post content (truncated)
  - [ ] Likes count
  - [ ] Comments count
  - [ ] Like, Comment, and View buttons

**Pass Criteria:** All post data visible and formatted correctly

---

### Test 2: Pull-to-Refresh ✅

**Objective:** Verify refresh functionality works

**Steps:**
1. In Community Feed
2. Pull down (swipe from top)
3. Release and wait

**Expected Results:**
- [ ] Refresh indicator appears
- [ ] Posts reload
- [ ] Indicator disappears
- [ ] Feed updates

**Pass Criteria:** Refresh animation smooth, data reloads

---

### Test 3: Like/Unlike Posts ✅

**Objective:** Test post liking functionality

**Steps:**
1. In Community Feed
2. Tap "Like" button on a post
3. Observe button state change
4. Tap again to unlike

**Expected Results:**
- [ ] Button text changes to "Liked"
- [ ] Button color changes to red
- [ ] Like count increases
- [ ] Tap again removes like
- [ ] Like count decreases

**Pass Criteria:** Like state toggles correctly, UI updates

---

### Test 4: View Post Details ✅

**Objective:** Test navigation to post detail screen

**Steps:**
1. In Community Feed
2. Tap "View" button on any post
3. Observe screen transition

**Expected Results:**
- [ ] PostDetailScreen appears
- [ ] Full post content visible
- [ ] Author info displayed with larger avatar
- [ ] Post stats (likes, comments) visible
- [ ] Comments section loads
- [ ] Comment input field at bottom
- [ ] Back button returns to feed

**Pass Criteria:** Navigation works smoothly, all details display

---

### Test 5: Comments Section ✅

**Objective:** Verify comments load and display

**Steps:**
1. In PostDetailScreen
2. Scroll down to comments section
3. Observe comment list

**Expected Results:**
- [ ] "Comments" header visible
- [ ] Each comment shows:
  - [ ] Author avatar
  - [ ] Author name (clickable in future)
  - [ ] Comment text
  - [ ] Comment timestamp
- [ ] Empty state if no comments: "No comments yet. Be the first!"
- [ ] Comments organized by timestamp

**Pass Criteria:** Comments display properly with all fields

---

### Test 6: Add Comment ✅

**Objective:** Test comment submission

**Steps:**
1. In PostDetailScreen
2. Tap comment input field
3. Type a comment message
4. Tap send button (circle icon)

**Expected Results:**
- [ ] Keyboard appears
- [ ] Comment text editable
- [ ] Send button enabled
- [ ] Loading indicator shows briefly
- [ ] Success snackbar appears ("Comment posted!")
- [ ] Comment appears in list
- [ ] Input field clears
- [ ] Comment count increases on post

**Pass Criteria:** Comment submits, displays, and UI updates

---

### Test 7: Create New Post ✅

**Objective:** Test post creation flow

**Steps:**
1. In Community Feed
2. Tap FAB (floating action button, "+" icon)
3. CreatePostScreen appears
4. Fill in form:
   - Title: "My First Post"
   - Content: "This is a test post for UniMates community"
5. Tap "Post" button

**Expected Results:**
- [ ] FAB is accessible and visible
- [ ] CreatePostScreen appears with:
  - [ ] Title field with label
  - [ ] Content field with label
  - [ ] Post and Cancel buttons
- [ ] Form validates:
  - [ ] Title requires 5+ characters
  - [ ] Content requires 10+ characters
- [ ] Loading indicator shows during submission
- [ ] Success snackbar appears ("Post created successfully!")
- [ ] Screen pops back to feed
- [ ] Feed refreshes automatically

**Pass Criteria:** Post creates successfully, navigation smooth

---

### Test 8: Form Validation ✅

**Objective:** Verify form validation rules

**Scenario A - Short Title:**
1. CreatePostScreen
2. Title: "Hi"
3. Content: "Long enough content here"
4. Tap Post

**Expected:** Error message: "Title must be at least 5 characters"

**Scenario B - Short Content:**
1. CreatePostScreen
2. Title: "Valid Title"
3. Content: "Short"
4. Tap Post

**Expected:** Error message: "Content must be at least 10 characters"

**Scenario C - Long Title:**
1. CreatePostScreen
2. Title: 101+ characters
3. Content: "Valid content here"
4. Tap Post

**Expected:** Error message: "Title must be less than 100 characters"

**Scenario D - Long Content:**
1. CreatePostScreen
2. Title: "Valid"
3. Content: 2001+ characters
4. Tap Post

**Expected:** Error message: "Content must be less than 2000 characters"

**Pass Criteria:** All validation messages appear correctly

---

### Test 9: Character Counter ✅

**Objective:** Verify character counter displays correctly

**Steps:**
1. CreatePostScreen
2. Observe content field
3. Type characters
4. Watch counter update

**Expected Results:**
- [ ] Counter shows "0/2000" initially
- [ ] Counter updates as you type
- [ ] Shows "25/2000" if 25 chars typed
- [ ] Counter turns red or warning at high count
- [ ] Counter accurate

**Pass Criteria:** Counter accurate and updates in real-time

---

### Test 10: Error Handling ✅

**Objective:** Test error scenarios

**Scenario A - Network Error:**
1. Community Feed
2. Pull-to-refresh multiple times
3. (Simulates potential error)

**Expected:** Error dialog or error state with retry button

**Scenario B - Invalid Comment:**
1. PostDetailScreen
2. Try to submit empty comment

**Expected:** Send button disabled, no action

**Scenario C - Empty Feed:**
1. If no mock data loads

**Expected:** Empty state message: "No posts yet"

**Pass Criteria:** Errors handled gracefully

---

### Test 11: Navigation ✅

**Objective:** Test bottom tab navigation

**Steps:**
1. In Community Feed
2. Tap "Marketplace" tab
3. Tap "Messaging" tab
4. Tap "Lost & Found" tab
5. Tap "Profile" tab
6. Return to Community

**Expected Results:**
- [ ] Each tab shows appropriate screen
- [ ] Marketplace: "Coming in Phase 3"
- [ ] Messaging: "Coming in Phase 4"
- [ ] Lost & Found: "Coming in Phase 5"
- [ ] Profile: User email and logout button
- [ ] Tabs highlight when active
- [ ] Quick transition between tabs
- [ ] Community Feed state preserved if switching away and back

**Pass Criteria:** Navigation smooth, all tabs functional

---

### Test 12: Profile & Logout ✅

**Objective:** Test profile screen and logout

**Steps:**
1. Tap Profile tab
2. Observe profile info
3. Tap Logout button
4. Confirm logout

**Expected Results:**
- [ ] Profile shows:
  - [ ] User avatar
  - [ ] User email
  - [ ] Member since message
- [ ] Menu items visible but show "Coming in Phase 6"
- [ ] Logout button is red
- [ ] Confirm dialog appears on logout
- [ ] Tap "Logout" → returns to AuthScreen
- [ ] App is ready to login again

**Pass Criteria:** Profile displays correctly, logout works

---

### Test 13: Responsiveness ✅

**Objective:** Test UI on different screen sizes

**Steps:**
1. Test on different emulator devices:
   - Small phone (4.7")
   - Medium phone (5.5")
   - Large phone (6.5")
   - Tablet (if available)

**Expected Results:**
- [ ] UI responsive on all sizes
- [ ] Text readable
- [ ] Buttons touchable
- [ ] No content cut off
- [ ] Proper spacing maintained

**Pass Criteria:** UI looks good on all screen sizes

---

### Test 14: Performance ✅

**Objective:** Test app performance

**Steps:**
1. Load feed with many posts
2. Scroll fast through feed
3. Create multiple posts
4. Navigate between screens
5. Monitor frame rate

**Expected Results:**
- [ ] Feed scrolls smoothly
- [ ] No jank or stutters
- [ ] Navigation is quick
- [ ] Loading times acceptable
- [ ] No memory leaks
- [ ] App doesn't crash

**Pass Criteria:** All interactions smooth and responsive

---

### Test 15: Integration Test ✅

**Objective:** Complete user workflow

**Steps:**
1. Login with email/password or Google
2. Navigate to Community
3. View feed (5-10 posts)
4. Like a post
5. View post details
6. Add a comment
7. Create a new post
8. Logout

**Expected Results:**
- [ ] All steps complete without errors
- [ ] Data persists appropriately
- [ ] Navigation smooth
- [ ] UI consistent
- [ ] No crashes

**Pass Criteria:** Complete workflow functional

---

## Bug Report Template

If you find issues, document them as:

```
**Bug Title:** [Specific issue]

**Reproduction Steps:**
1. Step 1
2. Step 2
3. ...

**Expected Behavior:**
What should happen

**Actual Behavior:**
What actually happens

**Device/Emulator:**
- Device model: 
- Android version: 
- Flutter version: 

**Screenshots/Logs:**
[Include relevant error messages]

**Severity:**
- [ ] Critical (app crashes)
- [ ] High (feature broken)
- [ ] Medium (unexpected behavior)
- [ ] Low (cosmetic issue)
```

---

## Performance Benchmarks

### Expected Metrics
- **Feed Load Time:** < 500ms
- **Post Refresh:** < 300ms
- **Comment Submit:** < 400ms
- **Post Creation:** < 500ms
- **Navigation:** < 200ms per tab switch
- **Scroll FPS:** 60 FPS on most devices

### Test Commands
```bash
# Run with verbose logging
flutter run -v

# Test build
flutter build apk --release

# Check diagnostics
flutter doctor -v
```

---

## Regression Testing Checklist

After any Phase 2 changes, verify:

- [ ] Phase 1 Auth Still Works
  - [ ] Email/password login
  - [ ] Google sign-in
  - [ ] Logout

- [ ] Community Module
  - [ ] Feed loads
  - [ ] Likes work
  - [ ] Comments work
  - [ ] Post creation works
  - [ ] Refresh works

- [ ] Navigation
  - [ ] Bottom tabs work
  - [ ] Profile works
  - [ ] Logout works

- [ ] UI/UX
  - [ ] No visual glitches
  - [ ] Text readable
  - [ ] Buttons responsive
  - [ ] Forms work

---

## Test Results Template

```
Phase 2 Testing Results
Date: [DATE]
Tester: [NAME]
Device: [DEVICE]

Test 1 (Feed Loading): ✅ PASS / ❌ FAIL
Test 2 (Pull to Refresh): ✅ PASS / ❌ FAIL
Test 3 (Like/Unlike): ✅ PASS / ❌ FAIL
Test 4 (View Details): ✅ PASS / ❌ FAIL
Test 5 (Comments): ✅ PASS / ❌ FAIL
Test 6 (Add Comment): ✅ PASS / ❌ FAIL
Test 7 (Create Post): ✅ PASS / ❌ FAIL
Test 8 (Validation): ✅ PASS / ❌ FAIL
Test 9 (Character Counter): ✅ PASS / ❌ FAIL
Test 10 (Error Handling): ✅ PASS / ❌ FAIL
Test 11 (Navigation): ✅ PASS / ❌ FAIL
Test 12 (Profile/Logout): ✅ PASS / ❌ FAIL
Test 13 (Responsiveness): ✅ PASS / ❌ FAIL
Test 14 (Performance): ✅ PASS / ❌ FAIL
Test 15 (Integration): ✅ PASS / ❌ FAIL

Overall Result: ✅ ALL TESTS PASS / ❌ ISSUES FOUND

Notes: [Any findings or observations]
```

---

**Phase 2 Testing Complete! Ready for Phase 3! 🎉**
