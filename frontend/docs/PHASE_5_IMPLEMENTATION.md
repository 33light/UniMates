# Phase 5: Lost & Found Module - Implementation Guide

**Date:** February 4, 2026  
**Phase:** 5 of 6  
**Status:** 🟡 PLANNING & IMPLEMENTATION  
**Estimated Duration:** 3-4 weeks  

---

## 📋 Phase 5 Overview

**Objective:** Implement a lost & found item reporting and recovery system where students can report lost items, view found items, and help each other recover belongings.

**Current Status:**
- ✅ Data models exist (`LostFoundItem`, `LostFoundType`)
- ✅ Mock data file exists (`mock_lost_found.json`)
- ⏳ Screens are placeholders (need implementation)
- ⏳ Service methods need implementation

**Scope:** Build fully functional Lost & Found module with UI, service layer, and mock API integration.

---

## 🎯 Phase 5 Features

### Feature 1: Browse Lost & Found Items
**Screens:** `lost_found_home.dart`
**Functionality:**
- Display all lost/found items in a list/grid
- Filter by: Lost, Found, Location, Date
- Search by: Title, Description
- Show unresolved items first
- Pull-to-refresh to reload items

**UI Components:**
- AppBar with title "Lost & Found"
- Tab bar: "Lost" and "Found" filters
- Item cards showing:
  - Item image (primary photo)
  - Title
  - Location
  - Date lost/found
  - Reporter name
  - "Resolved" badge (if applicable)
- Floating action button: "Report Item"
- Floating action button: "Report Found Item"

**User Actions:**
1. User opens Lost & Found tab
2. Sees list of unresolved lost items
3. Can tap to view details
4. Can search or filter
5. Can tap FAB to report item

---

### Feature 2: Report Lost Item
**Screens:** `report_lost_item.dart`
**Functionality:**
- Form to report a lost item
- Collect information:
  - Item title (e.g., "Blue backpack")
  - Description (e.g., "Contains laptop and books")
  - Location lost (e.g., "Library, 2nd floor")
  - Date lost
  - Category (e.g., Electronics, Accessories, Clothing, Other)
  - Images (camera/gallery upload - mock)
  - Contact info (pre-filled from profile)

**Form Fields:**
```
[Title Text Field]
[Description Multi-line Text]
[Location Dropdown / Search]
[Date Picker] (defaults to today)
[Category Dropdown]
[Image Upload Button] (show 1-3 images)
[Submit Button]
```

**Validation:**
- ✅ Title: 3-50 characters
- ✅ Description: 10-500 characters
- ✅ Location: Not empty
- ✅ Category: Selected
- ✅ At least title required
- ✅ Date: Not in future

**Success:**
- Item added to list
- Show success snackbar
- Navigate back to list
- New item appears at top (newest first)

---

### Feature 3: Report Found Item
**Screens:** `report_found_item.dart` (similar to report lost)
**Functionality:**
- Form to report a found item
- Same fields as "Report Lost"
- Additional field: "What you found" (brief description)
- Option to suggest matching lost items

**UI Difference:**
- Tab or separate button for "Report Found"
- Type = "Found" instead of "Lost"
- Maybe show "Did you find a lost item?" with matching suggestions

---

### Feature 4: Item Details
**Screens:** `lost_found_item_detail.dart`
**Functionality:**
- Full item information display
- Image gallery (swipeable)
- Item details:
  - Large title
  - Description
  - Location with map (optional)
  - Date lost/found
  - Category badge
  - Reporter info (avatar, name, rating)
- Action buttons:
  - "Contact Finder/Reporter" (messaging)
  - "Mark as Resolved" (if reporter)
  - "Share Item" (share to other students)
  - "Similar Items" (show matching items)

**Information Display:**
```
[Image Gallery - swipeable]

[Title - Large]
[Category Badge]
[Resolved Badge - if applicable]

Location: [Location]
Date: [Date]
Type: Lost / Found

Description:
[Full description text]

Reporter:
[Avatar] [Name] ⭐ [Rating]
[Message Button]

[Related Items] - Similar lost/found items
```

---

### Feature 5: Mark as Resolved
**Functionality:**
- Only reporter can mark as resolved
- Shows confirmation dialog: "Found your item? Mark as resolved?"
- When resolved:
  - Item moves to bottom of list
  - "Resolved" badge appears
  - Can still be viewed but grayed out
  - Marked with ✅ status

---

## 📊 Data Models & Structures

### LostFoundItem (Already Exists)
```dart
class LostFoundItem {
  String id;
  String reporterId;
  String reporterName;
  String? reporterImage;
  String title;
  String description;
  String location;
  DateTime itemDate;        // Date lost/found
  List<String> imageUrls;
  LostFoundType type;       // Lost or Found
  bool isResolved;
  DateTime createdAt;       // When reported
  String? resolvedBy;       // Who helped resolve (optional)
}

enum LostFoundType {
  lost,
  found
}
```

### Mock Data Structure (`mock_lost_found.json`)
```json
{
  "items": [
    {
      "id": "lf_001",
      "reporterId": "user_1",
      "reporterName": "Alice Johnson",
      "reporterImage": "https://...",
      "title": "Blue Backpack",
      "description": "Contains laptop and textbooks. HP logo on front.",
      "location": "Library, 2nd Floor",
      "itemDate": "2024-02-01T10:00:00Z",
      "imageUrls": ["https://...", "https://..."],
      "type": "lost",
      "isResolved": false,
      "createdAt": "2024-02-01T14:30:00Z",
      "resolvedBy": null,
      "category": "Electronics"
    }
  ]
}
```

---

## 🔧 Service Layer Implementation

**File:** `lib/services/mock_api_service.dart`

### Methods to Add:

#### 1. `getLostFoundItems()`
```dart
Future<List<LostFoundItem>> getLostFoundItems({
  LostFoundType? type,
  String? location,
  bool? unresolved
}) async {
  // Load from mock_lost_found.json
  // Filter by type, location, resolved status
  // Sort: unresolved first, then by date (newest)
  // Simulate 300-400ms delay
  // Return List<LostFoundItem>
}
```

#### 2. `getLostFoundItem(id)`
```dart
Future<LostFoundItem?> getLostFoundItem(String id) async {
  // Get single item by ID
  // Return LostFoundItem or null
}
```

#### 3. `reportLostItem(item)`
```dart
Future<bool> reportLostItem(LostFoundItem item) async {
  // Add new lost item to list
  // Generate unique ID
  // Set createdAt = now, isResolved = false
  // Return bool success
}
```

#### 4. `reportFoundItem(item)`
```dart
Future<bool> reportFoundItem(LostFoundItem item) async {
  // Add new found item to list
  // Generate unique ID
  // Set type = "found"
  // Return bool success
}
```

#### 5. `markItemResolved(itemId, userId)`
```dart
Future<bool> markItemResolved(String itemId, String userId) async {
  // Mark item as resolved
  // Only if userId is reporter
  // Set isResolved = true, resolvedBy = userId
  // Return bool success
}
```

#### 6. `searchLostFoundItems(query)`
```dart
Future<List<LostFoundItem>> searchLostFoundItems(String query) async {
  // Search by title, description, location
  // Case-insensitive
  // Return matching items
}
```

#### 7. `getItemsByLocation(location)`
```dart
Future<List<LostFoundItem>> getItemsByLocation(String location) async {
  // Filter items by location
  // Support partial matching
  // Return filtered list
}
```

---

## 📁 Files to Create/Modify

### New Files:
```
lib/screens/lost_found/
├─ lost_found_home.dart          (550+ lines) [Browse items]
├─ report_lost_item.dart         (400+ lines) [Report form]
├─ report_found_item.dart        (400+ lines) [Report form]
└─ lost_found_item_detail.dart   (450+ lines) [Item details]

assets/data/
└─ mock_lost_found.json          [10+ sample items]
```

### Modified Files:
```
lib/services/mock_api_service.dart
  - Add 7 new methods for Lost & Found operations
  - Load mock_lost_found.json in constructor

lib/models/app_models.dart
  - Verify LostFoundItem and LostFoundType exist ✅

lib/screens/lost_found_screen.dart
  - Replace placeholder with actual LostFoundHomeScreen

pubspec.yaml
  - Register mock_lost_found.json in assets
```

---

## 🎨 UI/UX Specifications

### Lost & Found Home Screen
- **AppBar:** "Lost & Found" with 2 tabs (Lost / Found)
- **Body:** TabBarView with 2 lists
- **List Items:** Dismissible cards with item info
- **FAB:** Split FAB menu:
  - "Report Lost Item"
  - "Report Found Item"
- **Empty State:** Icon + message if no items
- **Filters:** Location filter, date range filter

### Report Item Screens
- **Title:** "Report Lost Item" or "Report Found Item"
- **Form:** Vertically scrollable with all fields
- **Submit Button:** Disabled until valid
- **Success:** Navigate back with snackbar

### Item Detail Screen
- **AppBar:** Back button + Share button
- **Image Gallery:** Swipeable, pinch to zoom (optional)
- **Information Sections:**
  - Title + Badge
  - Description
  - Location + Map icon
  - Date
  - Reporter card with message button
- **Action Buttons:** Contact, Mark Resolved, Share
- **Related Items:** Section showing similar items

---

## ✅ Validation Rules

| Field | Rules | Error Message |
|-------|-------|---------------|
| Title | 3-50 chars, not empty | "Title must be 3-50 characters" |
| Description | 10-500 chars | "Description must be 10-500 characters" |
| Location | Not empty | "Location is required" |
| Date | Not in future | "Date cannot be in the future" |
| Category | Must select | "Please select a category" |
| Images | Optional | Can submit without images |

---

## 🧪 Testing Strategy

### Manual Test Scenarios (16 tests)

#### Test Set 1: Browse Items (4 tests)
1. Load items list
2. Filter by Lost/Found
3. Filter by location
4. Search by title

#### Test Set 2: Report Lost Item (5 tests)
1. Open report form
2. Validate form fields
3. Submit valid form
4. Item appears in list
5. Check item details

#### Test Set 3: Report Found Item (3 tests)
1. Open found item form
2. Submit form
3. Item marked as "Found"

#### Test Set 4: Item Details (2 tests)
1. Open item details
2. View all information

#### Test Set 5: Mark Resolved (2 tests)
1. Mark as resolved
2. Item moves to resolved state

---

## 📈 Implementation Timeline

### Week 1: Planning & Models
- ✅ Review data models (already exist)
- ✅ Create implementation plan (this document)
- ⏳ Prepare mock data file
- Estimate effort: 1 day

### Week 2: Browse & Detail Screens
- Create `lost_found_home.dart` (browse items)
- Create `lost_found_item_detail.dart` (view item)
- Add service methods (getLostFoundItems, getLostFoundItem, search)
- Add mock data
- Estimate effort: 5-6 days

### Week 3: Report Screens
- Create `report_lost_item.dart` (form)
- Create `report_found_item.dart` (form)
- Add service methods (reportLostItem, reportFoundItem)
- Form validation
- Estimate effort: 4-5 days

### Week 4: Polish & Testing
- Mark as resolved functionality
- Testing (16+ test scenarios)
- Bug fixes
- Performance optimization
- Estimate effort: 3-4 days

**Total:** 3-4 weeks

---

## 🔌 Integration Points

### Firebase (Future)
- Firestore collection: `lost_found_items`
- Storage: Item images
- Cloud Functions: Push notifications when similar items found

### Messaging Module
- "Contact Finder" button navigates to messaging
- Uses `getOrCreateConversation()` from Phase 4

### User Profile
- Reporter avatar/rating from user profile
- User ID validation for "Mark Resolved"

### Authentication
- Current user ID from FirebaseAuth
- Show "Mark Resolved" button only if user is reporter

---

## 📊 Success Criteria

✅ **Code Quality**
- 0 compilation errors
- 0 lint warnings
- Proper error handling
- Input validation on all forms

✅ **Features**
- All 5 features fully implemented
- All 7 service methods working
- Mock data loads correctly
- All screens render properly

✅ **Testing**
- All 16+ test scenarios pass
- No crashes
- Smooth navigation
- Form validation works

✅ **Performance**
- List scrolls smoothly (60 FPS)
- Images load quickly
- App memory < 300MB
- No memory leaks

✅ **Documentation**
- Code comments on complex logic
- Function documentation
- Screen documentation
- Service method documentation

---

## 🚀 Getting Started

### Step 1: Verify Models
```bash
# Check if LostFoundItem exists
grep "class LostFoundItem" lib/models/app_models.dart
```

### Step 2: Prepare Mock Data
```bash
# Create mock_lost_found.json with 10+ sample items
# Register in pubspec.yaml assets
```

### Step 3: Implement Service Methods
```dart
// Add methods to MockApiService
getLostFoundItems()
reportLostItem()
searchLostFoundItems()
// ... etc
```

### Step 4: Build Screens
```dart
// Create screens in lib/screens/lost_found/
lost_found_home.dart          // Browse items
lost_found_item_detail.dart   // View item
report_lost_item.dart         // Report form
```

### Step 5: Test
```bash
# Run flutter and test all features
flutter run
```

---

## 📚 Reference Documentation

**Related Documents:**
- [UNIMATES_PROJECT_PLAN.md](UNIMATES_PROJECT_PLAN.md) - Phase 5 specifications
- [PHASE_4_IMPLEMENTATION.md](PHASE_4_IMPLEMENTATION.md) - Similar implementation guide
- [00_START_HERE.md](00_START_HERE.md) - Quick reference guide

**Architecture References:**
- [PHASE_2_ARCHITECTURE.md](PHASE_2_ARCHITECTURE.md) - Layered architecture pattern
- [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) - Folder organization

---

**Ready to start Phase 5? Begin with Step 1: Verify Models** ✅

