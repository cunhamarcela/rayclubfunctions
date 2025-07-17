# Dashboard Feature

The Dashboard feature provides a comprehensive view of the user's fitness journey, pulling together data from various parts of the app into a single, unified interface.

## Components

### Models
- `DashboardData`: Main data model that holds all dashboard information

### Repository
- `DashboardRepository`: Connects to Supabase to fetch dashboard data

### ViewModel
- `DashboardViewModel`: Manages state and provides methods for water tracking

### UI Components
- `ProgressDashboardWidget`: Shows workout statistics and streaks
- `WaterIntakeWidget`: Tracks daily water consumption
- `WorkoutCalendarWidget`: Displays workout history in calendar format
- `GoalsWidget`: Shows progress towards user-defined goals

## Data Flow

```
Supabase Tables (user_progress, water_intake, etc.)
            ↓
     DashboardRepository 
            ↓
     DashboardViewModel
            ↓
UI Widgets (ProgressDashboard, WaterIntake, etc.)
```

## Database Requirements

The dashboard relies on these Supabase tables:
- `user_progress`: Overall user statistics
- `water_intake`: Daily water consumption records
- `workout_records`: Individual workout entries
- `user_goals`: User-defined goals and targets

## SQL Functions

- `get_dashboard_data`: SQL function that fetches all dashboard data in a single call

## Usage

Access the dashboard from the app drawer or by navigating to the dashboard route.

```dart
// Navigate to dashboard
context.router.push(const DashboardRoute());
``` 