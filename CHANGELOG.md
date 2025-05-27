# Changelog

All notable changes to this project will be documented in this file.

## [Released]

## [0.1.69] - 2025-05-27

- Update: Moved from supabase to better auth
- Update: Migrated to AWS EKS and ECR from GCP
- Update: Separated concerns between secrets, configmaps, environment variables, and extraEnvVars
- Build bump
- Rewrote templates for better maintainability

## [0.1.68] - 2025-05-09

- Colour bars in realtime sessions by type
- Bulk download sessions
- Total latency
- Live session updates
- Averages
- Show full conversation rendered mode
- Accurate turn timing

## [0.1.67] - 2025-05-06

- fixed cors issue with jawn

## [0.1.66] - 2025-05-05

- new sessions view and sessions page

## [0.1.65] - 2025-04-29

- small bug fixes

## [0.1.64] - 2025-04-29

- fixed jawn log table not found

## [0.1.63] - 2025-04-27

# Updates

- Download raw session logs (for fine-tuning)
- Attempt to fix audio playback issue
- 2 way sync between Gannt chart and timeline views
- Unified session timeline with realtime

## [0.1.62] - 2025-04-21

# Updates

- Build bump

## [0.1.61] - 2025-04-11

# Updates

- Build bump

## [0.1.60] - 2025-04-11

# Updates

- Build bump

## [0.1.59] - 2025-04-10

# Updates

- New: Deleted messages are now displayed with special considerations
- Update: Now using ffmpeg for better audio format conversion and gain control
- Update: Cost calculation support added for realtime models
- Fix: Assistant request dark mode missing
- Fix: Annoying logs in jawn

## [0.1.58] - 2025-04-02

# Updates

- Add's custom logging endpoint so that we can use the HeliconeManualLogger with jawn.

## [0.1.57] - 2025-03-26

# Updates

- New: Support for realtime Azure provider
- Fix: Checking before converting to WAV

## [0.1.56] - 2025-03-19

# Updates

- Fix: New safer parsing in mapper

## [0.1.55] - 2025-03-18

# Updates

- Hotfix: Now finding startingSession

## [0.1.54] - 2025-03-18

# Updates

- Hotfix: Use safeJsonParse for all linked messages

## [0.1.53] - 2025-03-07

# Updates

- Hotfix: Realtime session UI validation
- Update: Session table now contains clickable links

## [0.1.52] - 2025-03-05

- Image tags misaligned - fixed

## [0.1.51] - 2025-03-04

### Updates

- New: Full Sessions support
- New: Realtime mapper and UI now correctly display audio data with full playback and download
- New: Realtime Session highlighter
- Update: Various tweaks and improvements to realtime messages UX
- Fix: Also mapping input_text type messages as text
- Fix: Tokens now logging for realtime

## [0.1.50] - 2025-02-17

### Updates

- Misc fixes

## [0.1.49] - 2025-02-17

### Updates

- More logs on auth debug page

## [0.1.48] - 2025-02-17

### Updates

- Added `auth-debug` page to show the auth headers being sent to Helicone, and extra debugging information

## [0.1.47] - 2025-02-14

### Updates

- Fix: Corrected mapping of conversation.item.input_audio_transcription.completed transcript
- Update: Improved Realtime session updates and header styles
- Fix: Helicone properties correctly given to log now
- Misc: examples improvement

## [0.1.47] - 2025-02-14

### Updates

- Fix: Corrected mapping of conversation.item.input_audio_transcription.completed transcript
- Update: Improved Realtime session updates and header styles
- Fix: Helicone properties correctly given to log now
- Misc: examples improvement

## [0.1.46] - 2025-02-13

### Updates

- Improved realtime message handling and sanitization
- Fixed message content handling for empty or null messages
- Optimized message key generation in realtime components
- Enhanced function call output handling in realtime mapper

## [0.1.45] - 2025-02-13

### Updates

- Realtime Initial message buffer support

## [0.1.44] - 2025-02-11

### Updates

- Realtime API support

## [0.1.43] - 2025-01-21

### Updates

- Clickhouse migration runner now uses python
- Migrations should be more reliable

## [0.1.42] - 2024-01-20

### Updates

- Environment variables are dynamically loaded into the web app
- Allowing for the build first + deploy everywhere technique to be used

## [0.1.41] - 2024-12-13

### Updates

- Experiments improvements
- Can now create new prompmts in experiments that have auto inputs
- fixed scrolling on preview window for prompts
- Added ability to scroll when creating a new prompt
- Moved to old markdown editor but uses Monaco editor for large requests

## [0.1.40] - 2024-12-10

### Updates

- Removed all cyclical dependencies to improve build times on web
- Playgrounds can be opened in new tabs
- Large requests render a lot faster (Moved to Monaco editor)
- adding 0 in time no longer crashes
- Time filters now allow you to select a date manually (previously it was only the range selector)

## [0.1.39] - 2024-12-03

### Updates

- Fixing small experiment bug

## [0.1.38] - 2024-12-02

### Updates

- Experiment scores

## [0.1.37] - 2024-12-02

### Updates

- Small housekeeping updates on Helm chart

## [0.1.36] - 2024-11-27

### Updates

- Add the ability to change and update keys within the UI

## [0.1.35] - 2024-11-26

### Updates

- Add the ability to change and update keys within the UI

## [0.1.33] - 2024-11-26

### Updates

- Major UI updates
- New experiments page with table view
- Session page improvements
- Fixes issue with Dashboard showing threats
- Webhooks enabled
- Evaluators can now be created and edited
- See changelog: https://www.helicone.ai/changelog

## [0.1.32] - 2024-09-25

### Updates

- Fixed experiment page not showing any experiments

## [0.1.31] - 2024-09-24

### Updates

- Allows users to specify a requestId in the url params for a session
- improvements to screen flashing on sessions page

## [0.1.30] - 2024-09-19

### Updates

- New sidebar
- Asset IDs (images) not getting rendered properly in the frontend

## [0.1.29] - 2024-09-13

### Updates

- New tables should be a lot more performant for aggregate metrics
- Sessions now have metrics associated with them
- New Prompts view and ability to edit prompts in the UI
- o1 support in playground
- Bugs and improvements around the playground
- Slack Alerts and Notifications

## [0.1.28] - 2024-08-12

### Updates

- Sessions metrics fixes
- Sessions can now be clicked in span view
- Sessions Tree view also shows Span view
- Optimistically reloading requests on requests table, improve initial render speeds
- New playground beta with better tool support

## [0.1.27] - 2024-07-25

### Fix

- Fixed a bug where the session page would not load

## [0.1.26] - 2024-07-22

### Updated

- Helicone Prompts with Auto Inputs Index
- We can now support chat like interactions with promps
- We can support multiple images in prompts

## [0.1.25] - 2024-07-19

### Updated

- Force Content Header to be nothing
- Session UI Updates

## [0.1.24] - 2024-07-12

### Updated

- Added a new proxy endpoint to JAWN

## [0.1.23] - 2024-07-04

### Updated

- Formatting for prompt input variables is now in markdown.
- Easier configuration of columns, which are now saved in your local storage for persistence across refreshes.
- Added a dedicated sort button to allow sorting in different views.
- Deleting a prompt now allows reuse of the same prompt variable name (note: the metrics over time graph will still contain old data, which is a known bug we are addressing).
- Resolved the issue with the prompt version header not working in certain environments. This was due to the payload size being sent to Jawn, which has now been fixed and tested with your prompts.

## [0.1.22] - 2024-06-14

### Updated

- Adds the ability to hardcode the Helicone prompt version to reduce new versions being created when an unknown number of images are passed.

## [0.1.21] - 2024-05-29

### Fix

- Fixed web project build

## [0.1.20] - 2024-05-28

### Updated

- Fixed web project build

## [0.1.19] - 2024-05-27

### Updated

- Scores can now accept booleans
- Requests that are not scored can be fetched

## [0.1.18] - 2024-05-24

### Updated

- Admin panel to configure and test Azure deployments

## [0.1.17] - 2024-05-17

### Updated

- deduplicate clickhouse request_response_versioned to fix price calc

## [0.1.16] - 2024-05-17

### Updated

- Write to clickhouse for dashboard

## [0.1.15] - 2024-05-17

### Updated

- Scores support in frontend
- Writing directly to jawn. Should allow us to support higher throughput.
- Prompt usage metrics
- Major bug fixes around property searches in request page
- property filters in dashboard
- Auto select model based on previous model
- Datasets are associated to a prompt now, so dataset list is filtered
- gpt-4o support
- deleting prompts
- prompt-mode header for testing

## [0.1.14] - 2024-05-1

### Updated

- Added OpenAI for experiments
- Added the ability to run experiments with images as inputs

## [0.1.13] - 2024-04-30

### Updated

- Update Jawn HELICONE_WORKER_URL to reference OAI service name instead of publicUrl
- Remove experiment ID when running an experiment
- Images as inputs now work in the prompts and inputs view
- Responses are now shown in the prompts and inputs view
- Image template support when creating new experiment
- React Diff Viewer is hidden preventing browser from crashing
- Auto complete Model on experiment curation

## [0.1.12] - 2024-04-27

### Fixed

- Fix ClickHouse migration error
- Add experiment debug logs
- Add oai publicUrl to values.yaml

## [0.1.11] - 2024-04-26

### Fixed

- Image support for both playground + prompts
- Image support for inputs \* (there is a small issue we are working on now)
- Database migration (cleaner inputs)
  - We basically hacked it in with custom properties to get it out to you orginally and get feedback, but now actually designed it and built it the correct way
- Scores
- Markdown support input fields

## [0.1.9] - 2024-04-18

### Fixed

- Feedback in the UI is now working and calling Jawn instead of worker

## [0.1.8] - 2024-04-18

### Fixed

- Playground now supports images
- Images that are sent to Helicone will be stored in a bucket. (This is a huge improvement!)
- Images are now supported in experiments as inputs

## [0.1.7] - 2024-03-28

### Fixed

- Experiments with OpenAI and Azure OpenAI Support
- API calls in worker
- Updates to web app (dashboard updates, filter persistence, etc)

## [0.1.6] - 2024-03-14

### Fixed

- Fix worker health checks failing

## [0.1.5] - 2024-03-13

### Fixed

- Reduce chart size by deleting old tgz versions

## [0.1.4] - 2024-03-13

### Updated

- Updated helicone docker image versions

## [0.1.3] - 2024-03-13

### Updated

- Added selectorLabels

## [0.1.1] - 2024-03-12

### Fixed

- Fixed spacing around selector labels

## [1.0.0] - 2024-03-11

### Added

- Launch initial helm version
