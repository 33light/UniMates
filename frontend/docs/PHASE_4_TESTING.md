# Phase 4: Messaging Module - Testing Guide

**Date:** February 4, 2026  
**Phase:** 4 of 6  
**Status:** 🟡 TESTING READY

---

## 📋 Test Overview

**Total Test Scenarios:** 26  
**Test Suites:** 4  
**Estimated Duration:** 2-3 hours  
**Environment:** Android Emulator / iOS Simulator / Physical Device

---

## 🧪 Test Suite 1: Conversation List (8 tests)

### Test 1.1: Load Conversation List
**Objective:** Verify conversation list loads correctly
**Steps:**
1. Launch app
2. Navigate to Messages tab (or click messaging icon)
3. Wait for list to load
4. Observe conversations displayed

**Expected Result:**
- ✅ Conversations list appears
- ✅ At least 3 sample conversations visible
- ✅ Each shows user avatar, name, last message, timestamp
- ✅ Unread badge displays on some conversations
- ✅ Loading spinner appears briefly then disappears

---

### Test 1.2: Conversation Displays Correct Data
**Objective:** Verify each conversation shows correct information
**Steps:**
1. Open conversations list
2. Examine first conversation card:
   - John Doe (should be otheruser name)
   - Last message visible
   - Timestamp (e.g., "2 hours ago")
   - Unread badge (if applicable)

**Expected Result:**
- ✅ User name displays correctly
- ✅ Last message preview shows (truncated if long)
- ✅ Timestamp formats correctly (e.g., "2h ago", "Yesterday")
- ✅ User avatar displays or shows placeholder

---

### Test 1.3: Unread Badge Shows Count
**Objective:** Verify unread message count badge
**Steps:**
1. Open conversations list
2. Look for conversations with unread > 0
3. Verify badge shows number
4. Tap conversation to open chat
5. Go back to list

**Expected Result:**
- ✅ Unread conversations show red badge with count
- ✅ Badge disappears after opening conversation
- ✅ Read conversations have no badge

---

### Test 1.4: Conversations Sort by Latest
**Objective:** Verify conversations sorted by newest message
**Steps:**
1. Open conversations list
2. Note order of conversations
3. Conversations should be newest first

**Expected Result:**
- ✅ Most recent conversation is at top
- ✅ Oldest conversation is at bottom
- ✅ Order matches lastMessageTime

---

### Test 1.5: Delete Conversation (with Confirmation)
**Objective:** Verify delete conversation with confirmation dialog
**Steps:**
1. Open conversations list
2. Swipe left on a conversation card
3. Red delete icon appears
4. Complete swipe or wait for confirmation
5. Tap "Delete" button in dialog
6. Confirm deletion

**Expected Result:**
- ✅ Swipe reveals delete action
- ✅ Confirmation dialog appears
- ✅ Dialog shows user name
- ✅ Cancel button returns to list
- ✅ Delete button removes conversation
- ✅ Conversation disappears from list
- ✅ Toast/snackbar shows "Conversation deleted"

---

### Test 1.6: Open Chat from Conversation
**Objective:** Verify tapping conversation opens chat
**Steps:**
1. Open conversations list
2. Tap on first conversation
3. Wait for chat screen to load

**Expected Result:**
- ✅ Chat screen opens
- ✅ User name shows in app bar
- ✅ Messages history displays
- ✅ Message input field appears at bottom

---

### Test 1.7: Empty State (No Conversations)
**Objective:** Verify empty state display (if manually cleared)
**Steps:**
1. Delete all conversations (manual test setup)
2. Return to conversations list
3. Observe empty state

**Expected Result:**
- ✅ Empty state icon displays
- ✅ "No conversations yet" message appears
- ✅ "Start a Chat" button visible
- ✅ Tapping button opens new conversation screen

---

### Test 1.8: FAB Opens New Conversation
**Objective:** Verify floating action button works
**Steps:**
1. Open conversations list
2. Tap floating action button (+ icon)
3. Wait for new conversation screen

**Expected Result:**
- ✅ FAB is visible in bottom right
- ✅ Tapping FAB opens new conversation screen
- ✅ Search field is ready for input

---

## 🧪 Test Suite 2: Chat Screen (12 tests)

### Test 2.1: Load Message History
**Objective:** Verify messages load when opening chat
**Steps:**
1. Open a conversation
2. Wait for messages to load
3. Observe message history

**Expected Result:**
- ✅ Messages load (loading spinner shows briefly)
- ✅ Messages display in chronological order
- ✅ Sender messages appear on right (blue)
- ✅ Receiver messages appear on left (gray)
- ✅ Each message shows timestamp

---

### Test 2.2: Message Bubbles Display Correctly
**Objective:** Verify message bubble styling
**Steps:**
1. Open chat screen with messages
2. Examine sender messages
3. Examine receiver messages

**Expected Result:**
- ✅ Sender messages: right-aligned, blue bubble, white text
- ✅ Receiver messages: left-aligned, gray bubble, dark text
- ✅ Messages have rounded corners
- ✅ Timestamps below messages

---

### Test 2.3: Send Message
**Objective:** Verify sending a new message
**Steps:**
1. Open chat screen
2. Type message in input field (e.g., "Hello!")
3. Tap send button (arrow icon)
4. Wait for confirmation

**Expected Result:**
- ✅ Text appears in input field
- ✅ Send button becomes enabled
- ✅ Message sends (loading indicator)
- ✅ New message appears in conversation
- ✅ Message appears on right side (sender)
- ✅ Input field clears
- ✅ Timestamp updates

---

### Test 2.4: Message Validation
**Objective:** Verify empty messages rejected
**Steps:**
1. Open chat screen
2. Tap send button without typing
3. Try sending whitespace only (spaces)

**Expected Result:**
- ✅ Send button disabled when field is empty
- ✅ Empty message not sent
- ✅ Whitespace-only message trimmed and not sent

---

### Test 2.5: Auto-scroll to Latest
**Objective:** Verify auto-scroll to newest message
**Steps:**
1. Open chat with many messages
2. Scroll to top (old messages)
3. Type and send new message
4. Observe scroll position

**Expected Result:**
- ✅ Chat auto-scrolls to bottom
- ✅ Latest message visible
- ✅ User doesn't manually scroll for new message

---

### Test 2.6: User Info Header
**Objective:** Verify header displays user information
**Steps:**
1. Open chat screen
2. Look at app bar

**Expected Result:**
- ✅ User name displays in title
- ✅ "Tap to view profile" subtitle shows
- ✅ Back arrow button visible (returns to list)

---

### Test 2.7: Back Button Returns to Conversations
**Objective:** Verify back navigation
**Steps:**
1. Open chat screen
2. Tap back arrow button
3. Observe return to conversations list

**Expected Result:**
- ✅ Chat screen closes
- ✅ Conversations list displays
- ✅ List is refreshed

---

### Test 2.8: Mark as Read on Open
**Objective:** Verify unread messages marked as read
**Steps:**
1. Go to conversations list
2. Find conversation with unread count (e.g., "2" badge)
3. Open that conversation
4. Return to conversations list

**Expected Result:**
- ✅ Unread badge disappears after opening
- ✅ Conversation no longer shows unread count

---

### Test 2.9: Multiple Messages Display Correctly
**Objective:** Verify handling of conversation with many messages
**Steps:**
1. Open chat with 10+ messages
2. Scroll through history
3. Send 3 new messages
4. Observe all messages display

**Expected Result:**
- ✅ All messages visible
- ✅ Scrolling smooth and fast
- ✅ No lag or stutter
- ✅ Messages in correct order

---

### Test 2.10: Timestamp Formatting
**Objective:** Verify timestamps display correctly
**Steps:**
1. Open chat screen
2. Observe message timestamps

**Expected Result:**
- ✅ Timestamps display in HH:MM format
- ✅ All timestamps readable
- ✅ Timestamps match actual message times

---

### Test 2.11: Input Field Focus
**Objective:** Verify input field behavior
**Steps:**
1. Open chat screen
2. Tap input field
3. Type message
4. Tap send
5. Tap input again

**Expected Result:**
- ✅ Input field gains focus (cursor visible)
- ✅ Keyboard appears
- ✅ Can type normally
- ✅ Keyboard dismisses after send
- ✅ Focus returns to input field for next message

---

### Test 2.12: Long Message Handling
**Objective:** Verify long messages display correctly
**Steps:**
1. Open chat screen
2. Type very long message (200+ chars)
3. Send message
4. Observe display

**Expected Result:**
- ✅ Long message wraps correctly
- ✅ Bubble expands to fit text
- ✅ No text overflow or clipping
- ✅ Message readable

---

## 🧪 Test Suite 3: New Conversation (6 tests)

### Test 3.1: Search Users
**Objective:** Verify user search functionality
**Steps:**
1. Open new conversation screen
2. Type user name in search field (e.g., "john")
3. Wait for search results

**Expected Result:**
- ✅ Search field has focus
- ✅ Results appear as user types
- ✅ Results show matching users
- ✅ User cards display correctly

---

### Test 3.2: User Card Display
**Objective:** Verify user search results show correct info
**Steps:**
1. Search for users
2. Examine result cards

**Expected Result:**
- ✅ User avatar displays
- ✅ User name shows
- ✅ Username shows (@username)
- ✅ University name visible
- ✅ Rating/verification badge shows
- ✅ "Message" button visible

---

### Test 3.3: Message Button Creates Conversation
**Objective:** Verify tapping message button starts conversation
**Steps:**
1. Search for user
2. Tap "Message" button on user card
3. Wait for chat screen

**Expected Result:**
- ✅ Chat screen opens
- ✅ New conversation created
- ✅ User name shows in header
- ✅ Empty message history (new conversation)
- ✅ Input field ready for message

---

### Test 3.4: Search Filter Works
**Objective:** Verify search filters by name and username
**Steps:**
1. Search for "john" - should find John Doe
2. Clear and search for "emily" - should find Emily Chen
3. Search for partial match "ali" - should find users with "ali" in name/username

**Expected Result:**
- ✅ Name search works
- ✅ Username search works
- ✅ Partial matches work
- ✅ Case-insensitive search

---

### Test 3.5: No Users Match Message
**Objective:** Verify empty state for no search results
**Steps:**
1. Search for non-existent user (e.g., "zzzzzzzzz")
2. Observe result

**Expected Result:**
- ✅ "No users found" message displays
- ✅ Empty state icon visible
- ✅ No crash or error

---

### Test 3.6: Clear Search
**Objective:** Verify clearing search returns to empty state
**Steps:**
1. Type search query
2. Tap X button to clear
3. Observe results

**Expected Result:**
- ✅ Search field clears
- ✅ Results disappear
- ✅ Empty state displays again
- ✅ Can search again

---

## 🧪 Test Suite 4: UI/UX & Performance (8 tests)

### Test 4.1: Responsive Layout - Mobile
**Objective:** Verify layout on mobile screen (375x667)
**Steps:**
1. Run app on mobile emulator/device
2. Open all messaging screens
3. Rotate to portrait
4. Rotate to landscape
5. Verify all elements visible

**Expected Result:**
- ✅ All elements visible in portrait
- ✅ All elements visible in landscape
- ✅ No cut-off text or buttons
- ✅ Layout adapts smoothly
- ✅ No horizontal scroll needed

---

### Test 4.2: Responsive Layout - Tablet
**Objective:** Verify layout on larger screens (600+)
**Steps:**
1. Run app on tablet emulator
2. Open messaging screens
3. Verify spacing and sizing

**Expected Result:**
- ✅ Elements properly spaced
- ✅ Message bubbles max-width reasonable (not full width)
- ✅ Readable and usable on larger screen

---

### Test 4.3: Dark Mode Support
**Objective:** Verify dark mode rendering
**Steps:**
1. Enable dark mode on device
2. Open all messaging screens
3. Verify colors and contrast

**Expected Result:**
- ✅ Dark mode theme applied
- ✅ All text readable
- ✅ Good contrast ratios
- ✅ Colors distinguish sender/receiver

---

### Test 4.4: Smooth Scrolling
**Objective:** Verify smooth message list scrolling
**Steps:**
1. Open chat with 20+ messages
2. Scroll through messages
3. Observe scroll performance

**Expected Result:**
- ✅ Scrolling smooth and responsive
- ✅ No stutter or lag
- ✅ 60 FPS maintained
- ✅ Scroll rebounds properly

---

### Test 4.5: Quick Actions
**Objective:** Verify button responsiveness
**Steps:**
1. Open conversations list
2. Quickly tap multiple conversations
3. Quickly send multiple messages
4. Rapidly swipe/delete conversations

**Expected Result:**
- ✅ Actions respond immediately
- ✅ No input lag
- ✅ UI remains responsive
- ✅ All actions complete successfully

---

### Test 4.6: Memory Usage
**Objective:** Verify reasonable memory consumption
**Steps:**
1. Monitor device memory before app
2. Send 10 messages in chat
3. Open 5 conversations
4. Monitor memory usage

**Expected Result:**
- ✅ App uses < 300MB RAM
- ✅ No memory leaks (stays stable)
- ✅ No app crash

---

### Test 4.7: Loading States
**Objective:** Verify loading indicators appear
**Steps:**
1. Open conversations list (initial load)
2. Open chat screen
3. Send message
4. Observe loading indicators

**Expected Result:**
- ✅ Loading spinner appears briefly
- ✅ Spinner disappears when done
- ✅ No stuck loading state
- ✅ Clear indication of state changes

---

### Test 4.8: Error Handling
**Objective:** Verify graceful error handling
**Steps:**
1. Simulate network issues (if possible)
2. Try to send message during network issue
3. Observe error handling

**Expected Result:**
- ✅ Error message displays if applicable
- ✅ User can retry action
- ✅ No app crash
- ✅ Clear error message (not technical jargon)

---

## ✅ Test Execution Checklist

| Test Suite | Tests | Status | Duration | Notes |
|-----------|-------|--------|----------|-------|
| Conversation List | 8 | ⬜ | 20 min | |
| Chat Screen | 12 | ⬜ | 40 min | |
| New Conversation | 6 | ⬜ | 20 min | |
| UI/UX & Performance | 8 | ⬜ | 30 min | |
| **TOTAL** | **34** | ⬜ | **110 min** | |

---

## 📝 Test Execution Template

### Tester Information
- **Name:** ________________
- **Device:** ________________ (e.g., Android Emulator API 33)
- **OS Version:** ________________
- **Date:** ________________
- **Time Started:** ________________

### Test Results

**Test Suite 1: Conversation List**
- [ ] Test 1.1: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 1.2: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 1.3: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 1.4: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 1.5: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 1.6: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 1.7: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 1.8: ✅ PASS / ⚠️ FAIL (notes: ___________)

**Test Suite 2: Chat Screen**
- [ ] Test 2.1: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 2.2: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 2.3: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 2.4: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 2.5: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 2.6: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 2.7: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 2.8: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 2.9: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 2.10: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 2.11: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 2.12: ✅ PASS / ⚠️ FAIL (notes: ___________)

**Test Suite 3: New Conversation**
- [ ] Test 3.1: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 3.2: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 3.3: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 3.4: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 3.5: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 3.6: ✅ PASS / ⚠️ FAIL (notes: ___________)

**Test Suite 4: UI/UX & Performance**
- [ ] Test 4.1: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 4.2: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 4.3: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 4.4: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 4.5: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 4.6: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 4.7: ✅ PASS / ⚠️ FAIL (notes: ___________)
- [ ] Test 4.8: ✅ PASS / ⚠️ FAIL (notes: ___________)

### Summary
- **Total Tests:** 34
- **Passed:** ___ / 34
- **Failed:** ___ / 34
- **Pass Rate:** ___%

### Issues Found
1. _____________________________________________________
2. _____________________________________________________
3. _____________________________________________________

### Sign-Off
- **Tester Signature:** ________________
- **Date:** ________________
- **Status:** 🟢 APPROVED / 🟡 APPROVE WITH NOTES / 🔴 REJECTED

---

**Ready to test? Run `flutter run` and begin testing!** 🚀

