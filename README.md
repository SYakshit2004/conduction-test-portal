# Conduction Test Portal (HTML, CSS, JavaScript + Supabase)

A responsive online test portal with student registration/login, administrator login, test creation, multiple-choice questions, timer, automatic score, and result dashboards. Uses Supabase free tier for authentication and PostgreSQL database. Static files deploy to GitHub Pages or Netlify.

## 1) Set up the free database and login
1. Create a free project at https://supabase.com (choose a database password and keep it safe).
2. Open **SQL Editor** in your project.
3. Paste all contents of `supabase_setup.sql` and run.
4. Go to **Project Settings → API**. Copy Project URL and the **anon/public** key.
5. Open `app.js`; replace:
   - `YOUR_SUPABASE_PROJECT_URL`
   - `YOUR_SUPABASE_ANON_KEY`
   with your project URL and anon/public key.
   Do NOT put a service-role/secret key in frontend files.
6. Publish files and open website. Create your student account.
7. To assign admin: Supabase **Authentication → Users**, copy your account UUID. In SQL Editor run:
   `update public.profiles set role='admin' where id='YOUR-UUID';`
   Log out and log back in. Admin access is database role controlled; never expose service role key.
8. Admin dashboard: create a test → add its questions → publish. Students can now take it.

## 2) Deploy with GitHub + Netlify
### GitHub
1. Create a repository (e.g. `conduction-test-portal`).
2. Upload `index.html`, `style.css`, `app.js`, `supabase_setup.sql`, `README.md` to repository root.
3. Commit changes. GitHub repository is your source code.

### Netlify (recommended for live website)
1. Sign in at https://app.netlify.com and choose **Add new site → Import an existing project**.
2. Connect GitHub and select your repository.
3. Build settings: **Build command: blank**; **Publish directory: `.`**.
4. Click Deploy. Netlify gives a `*.netlify.app` URL.
5. Each push to GitHub will trigger a redeploy automatically.

### GitHub Pages alternative
Repository → **Settings → Pages** → Deploy from branch → select `main` and `/ (root)` → Save. It publishes static frontend. GitHub Pages and Netlify do not host the Supabase database; Supabase provides the database/auth service.

## Important security note
This is a learning/demo MCQ test system. The answer keys are retrieved by the browser and scoring occurs client-side; a technically skilled student can inspect answers. Do not use for high-stakes exams. For secure exams, store answer keys separately and grade with a server-side function. Set Supabase email-confirmation and password policies appropriately.
