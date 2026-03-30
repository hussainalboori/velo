# ✅ To Do App (Day 3 / 10)

Welcome to **Day 3** of my **10 Days, 10 Apps Challenge**! 🚀

This is a polished, feature-rich **To-Do App** built with Flutter. It goes way beyond a simple checklist — with dynamic categories, subtasks, local persistence, and a clean architecture that keeps the code sharp and scalable.

## 🌟 Features
- **Clean UI**: A sleek gradient interface with smooth animated transitions between states — loading, empty, and list views all feel intentional.
- **Provider State Management**: All business logic lives in `TodoProvider`, completely isolated from the UI. Widgets are dumb by design — they only read state and fire events.
- **Full Task Editing**: Tap any task to open a detail screen where you can edit the title, description, category, add subtasks, and toggle them individually.
- **Dynamic Categories**: Create and delete your own categories on the fly. Tasks are safely re-assigned if a category is removed, and the last category is always protected.
- **Local Persistence**: Tasks and categories are saved to the device with `shared_preferences` and fully restored on the next launch — nothing gets lost.

## 💡 Inspiration & "The Twist"
Started from scratch with a clear goal: build a to-do app that's structured **the right way**, not the fast way.

**My Own Twist:** While the UI might look straightforward, the real work is under the hood. Every task and subtask is an **immutable model** mutated only through `copyWith`. A **busy-state guard** (`Set<String> busyItemIds`) prevents any task from being double-tapped during async operations. All user-facing strings and constants live in a single `AppConstants` / `AppStrings` file — zero hardcoded values in any widget. This is the kind of architecture you'd actually want to maintain.

## 🛠️ Built With
- **Flutter & Dart**
- **provider** (for state management)
- **shared_preferences** (for local persistence)
- **google_fonts** (Space Grotesk typography)

---
*Stay tuned for Day 4!* 💻✨
