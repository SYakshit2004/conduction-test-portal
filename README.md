# Conduction Test Portal

Includes student signup/login, admin dashboard, test creation, MCQs, timer, student results, manual score correction, Excel question import and Excel results export.

## Setup
1. Create a Supabase project.
2. Run `supabase_setup.sql` in SQL Editor.
3. Get Project URL and Publishable key from Project Settings > API Keys.
4. Replace `YOUR_SUPABASE_PROJECT_URL` and `YOUR_SUPABASE_PUBLISHABLE_KEY` in `app.js`. Never use the secret key in browser code.
5. Deploy the folder to GitHub and Netlify. Publish directory is `.` and build command is blank.
6. Register your account, copy its UUID from Authentication > Users, then run `update public.profiles set role='admin' where id='YOUR-UUID';` in SQL Editor. Log out and log in again.

## Excel question template columns
`Question`, `Option A`, `Option B`, `Option C`, `Option D`, `Correct Option` (A/B/C/D), `Marks`. Admin selects the destination test and imports the Excel file.

## Manual scores and result export
Admin dashboard > All student results > Edit score. Enter a whole number between 0 and maximum marks. Admin dashboard > Excel tools > select a test or All tests > Download results Excel.

## If database was already created with older SQL
Run this additional policy in Supabase SQL Editor to enable admin score corrections:
`create policy "admin updates results" on public.results for update using (public.is_admin()) with check (public.is_admin());`

Security note: this is a learning/demo MCQ platform. Correct answers are delivered to browser and scored client-side. Do not use for high-stakes exams without moving answer keys and grading to a trusted server-side function.
