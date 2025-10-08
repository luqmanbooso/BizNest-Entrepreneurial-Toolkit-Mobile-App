# 📅 Mentorship Session Scheduling System - Complete Guide

## 🎯 Overview
A full-featured session scheduling system that allows mentors to create mentorship sessions and both mentors and entrepreneurs to view and manage their sessions.

---

## 📁 Files Created

### 1. **Session Service** (`lib/core/services/session_service.dart`)
Backend service handling all session operations with Firebase Firestore.

**Functions:**
- `createSession()` - Create a new mentorship session
- `getMentorSessions()` - Get all sessions for a mentor
- `getEntrpreneurSessions()` - Get all sessions for an entrepreneur
- `getUpcomingSessions()` - Get upcoming sessions within next 7 days
- `updateSessionStatus()` - Update session status (scheduled/completed/cancelled)
- `deleteSession()` - Delete a session
- `getMentorMentees()` - Get list of mentees from accepted mentorship requests

### 2. **Schedule Session Screen** (`lib/screens/schedule_session_screen.dart`)
UI for mentors to create new mentorship sessions.

**Features:**
- Dropdown to select mentee (from accepted mentorship requests)
- Session title and topic input
- Date picker (can't schedule in the past)
- Time picker
- Duration selector (30, 45, 60, 90, 120 minutes)
- MS Teams / meeting link input
- Optional notes field
- Full form validation
- Loading states and error handling

### 3. **Sessions Screen** (`lib/screens/sessions_screen.dart`)
View for both mentors and entrepreneurs to see their sessions.

**Features:**
- Filter tabs: Upcoming / Completed / All
- Session cards showing:
  - Session title and topic
  - Mentor/Mentee name
  - Date, time, duration
  - Status badge (color-coded)
  - Meeting link (copies to clipboard on tap)
  - Notes
- "Join Meeting" button for upcoming sessions
- Cancel session functionality (with confirmation)
- Empty state when no sessions
- Responsive design

---

## 🔧 Integration Points

### Mentor Dashboard
**Location:** `lib/screens/mentor_dashboard_screen.dart`

**Added:**
1. Import: `session_service.dart` and `sessions_screen.dart`
2. Sidebar Menu Items:
   - 📅 "Schedule Session" - Opens schedule session screen
   - 📋 "My Sessions" - Opens sessions list (isMentor: true)
3. Upcoming Sessions Widget:
   - Now loads from Firebase via `SessionService.getUpcomingSessions()`
   - Displays real scheduled sessions instead of mock data

### Professional Dashboard (Entrepreneur)
**Location:** `lib/screens/professional_dashboard_screen.dart`

**Added:**
1. Import: `sessions_screen.dart`
2. Side Menu (only shows if user has accepted mentorship requests):
   - 📋 "Sessions" - Opens sessions list (isMentor: false)

---

## 🗄️ Firebase Structure

### Collection: `sessions`

**Document Fields:**
```dart
{
  'id': String,                    // Auto-generated document ID
  'mentor_id': String,             // Mentor's user ID
  'mentor_name': String,           // Mentor's display name
  'mentee_id': String,             // Entrepreneur's user ID
  'mentee_name': String,           // Entrepreneur's display name
  'session_title': String,         // e.g., "Business Strategy Review"
  'session_topic': String,         // e.g., "Marketing Strategy"
  'scheduled_date': Timestamp,     // Date of the session
  'scheduled_time': String,        // Time in 12-hour format
  'duration_minutes': int,         // 30, 45, 60, 90, or 120
  'meeting_link': String,          // MS Teams or any meeting URL
  'notes': String,                 // Optional additional notes
  'status': String,                // 'scheduled', 'completed', 'cancelled'
  'created_at': Timestamp,         // When session was created
  'updated_at': Timestamp,         // Last update time
}
```

### Required Indexes
For optimal performance, create these composite indexes in Firebase Console:

1. **Mentor Sessions Query:**
   - Collection: `sessions`
   - Fields: `mentor_id` (Ascending), `scheduled_date` (Ascending)

2. **Entrepreneur Sessions Query:**
   - Collection: `sessions`
   - Fields: `mentee_id` (Ascending), `scheduled_date` (Ascending)

3. **Upcoming Sessions Query:**
   - Collection: `sessions`
   - Fields: `mentor_id` (Ascending), `status` (Ascending), `scheduled_date` (Ascending)

4. **Upcoming Sessions Query (Mentee):**
   - Collection: `sessions`
   - Fields: `mentee_id` (Ascending), `status` (Ascending), `scheduled_date` (Ascending)

---

## 🚀 User Flow

### For Mentors:

1. **Schedule a Session:**
   ```
   Dashboard → Sidebar → Schedule Session
   → Select mentee
   → Fill in details
   → Add meeting link
   → Submit
   ```

2. **View Sessions:**
   ```
   Dashboard → Sidebar → My Sessions
   → Filter by status
   → View details
   → Copy meeting link
   → Cancel if needed
   ```

3. **Dashboard View:**
   ```
   Dashboard → Upcoming Sessions widget
   → Shows next 7 days
   → Quick access to session details
   ```

### For Entrepreneurs:

1. **View Sessions:**
   ```
   Dashboard → More Menu → Sessions
   → Filter by status
   → View details
   → Copy meeting link to join
   ```

2. **When Session Time Comes:**
   ```
   Sessions → Upcoming tab
   → Tap "Join Meeting"
   → Meeting link copied to clipboard
   → Open browser/Teams and paste link
   ```

---

## 🎨 UI Features

### Schedule Session Screen:
- ✅ Electric blue theme matching app design
- ✅ Native date/time pickers
- ✅ Chip selector for duration
- ✅ Form validation with error messages
- ✅ Loading spinner during submission
- ✅ Success/error notifications
- ✅ Empty state if no mentees

### Sessions Screen:
- ✅ Filter tabs with smooth transitions
- ✅ Color-coded status badges:
  - 🟢 Green: Scheduled
  - 🔵 Blue: Completed
  - 🔴 Red: Cancelled
- ✅ Card-based layout with shadows
- ✅ Icon-based information display
- ✅ Action buttons (Join/Cancel)
- ✅ Empty state illustrations
- ✅ Copy to clipboard for meeting links

---

## 🔐 Security Considerations

1. **Authentication:**
   - All operations require logged-in user
   - User ID from `AuthService.currentUser`

2. **Authorization:**
   - Mentors can only create sessions for their mentees
   - Users can only view their own sessions
   - Cancel only works for upcoming sessions

3. **Validation:**
   - Can't schedule in the past
   - Must select valid mentee
   - Meeting link URL validation
   - Required fields enforced

---

## 🧪 Testing Checklist

### Mentor Side:
- [ ] Can view accepted mentees in dropdown
- [ ] Can select date in the future
- [ ] Can select time
- [ ] Can enter meeting link
- [ ] Form validation works
- [ ] Session appears in "My Sessions"
- [ ] Session appears in "Upcoming Sessions" widget
- [ ] Can cancel upcoming session
- [ ] Can't cancel past sessions
- [ ] Meeting link copies to clipboard

### Entrepreneur Side:
- [ ] "Sessions" menu only shows if has accepted mentorship
- [ ] Can view scheduled sessions
- [ ] Can see mentor name and details
- [ ] Can copy meeting link
- [ ] Filter tabs work correctly
- [ ] Empty state shows when no sessions

---

## 📱 Status Bar Management

Both Schedule Session and Sessions screens use `AnnotatedRegion` to set:
- Status bar color: Electric Blue
- Status bar icons: Light/White
- Matches the app bar for seamless UI

---

## 🔄 Real-time Updates

- Mentor dashboard refreshes after creating a session
- Sessions list reloads after canceling
- Uses Firebase Firestore for real-time data
- Automatic date/time sorting

---

## 💡 Tips for Users

1. **Meeting Links:**
   - Works with MS Teams, Zoom, Google Meet, any URL
   - Link is copied to clipboard when tapped
   - Paste in browser or Teams app to join

2. **Session Management:**
   - Cancel before session time if needed
   - Mark as completed after finishing (future feature)
   - View notes for preparation

3. **Best Practices:**
   - Schedule at least 1 hour in advance
   - Add detailed notes for preparation
   - Use consistent meeting platform

---

## 🚧 Future Enhancements

Potential additions:
- [ ] Email/push notifications
- [ ] Calendar integration
- [ ] Recurring sessions
- [ ] Video call integration
- [ ] Session feedback/rating
- [ ] Automatic status update to "completed"
- [ ] Session history and analytics
- [ ] Export sessions to calendar
- [ ] Reminder notifications

---

## 📞 Support

If you encounter issues:
1. Check Firebase indexes are created
2. Verify user has accepted mentorship requests
3. Check console logs for error messages
4. Ensure internet connection for Firebase

---

**Created:** October 7, 2025
**Version:** 1.0.0
**Status:** ✅ Fully Functional
