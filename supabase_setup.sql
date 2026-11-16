-- 1. Paste this into Supabase SQL Editor and run.
-- 2. In Supabase Auth, turn on email confirmation as desired.
create table public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 email text not null,
 role text not null default 'student' check (role in ('student','admin')),
 created_at timestamptz default now()
);
create table public.tests (
 id uuid primary key default gen_random_uuid(),
 title text not null,
 description text default '',
 duration_minutes integer not null check(duration_minutes between 1 and 180),
 is_published boolean not null default false,
 created_by uuid not null references public.profiles(id),
 created_at timestamptz default now()
);
create table public.questions (
 id uuid primary key default gen_random_uuid(),
 test_id uuid not null references public.tests(id) on delete cascade,
 question_text text not null,
 options jsonb not null check(jsonb_array_length(options)=4),
 correct_answer integer not null check(correct_answer between 0 and 3),
 marks integer not null default 1 check(marks > 0),
 created_at timestamptz default now()
);
create table public.results (
 id uuid primary key default gen_random_uuid(),
 student_id uuid not null references public.profiles(id),
 test_id uuid not null references public.tests(id),
 score integer not null,
 total integer not null,
 answers jsonb not null default '{}',
 submitted_at timestamptz default now()
);
-- Create profile automatically for newly registered accounts.
create function public.handle_new_user() returns trigger language plpgsql security definer set search_path=public as $$
begin
 insert into public.profiles(id,email,role) values(new.id,new.email,'student');
 return new;
end; $$;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();

alter table public.profiles enable row level security;
alter table public.tests enable row level security;
alter table public.questions enable row level security;
alter table public.results enable row level security;

create function public.is_admin() returns boolean language sql stable security definer set search_path=public as $$
 select exists(select 1 from public.profiles where id=auth.uid() and role='admin');
$$;
-- profiles: users can read own profile; admin can read all. No client-side role update allowed.
create policy "profile read own or admin" on public.profiles for select using (id=auth.uid() or public.is_admin());
-- tests: students see published tests; admins manage tests.
create policy "published tests readable" on public.tests for select using (is_published or public.is_admin());
create policy "admin creates tests" on public.tests for insert with check (public.is_admin() and created_by=auth.uid());
create policy "admin updates tests" on public.tests for update using (public.is_admin()) with check (public.is_admin());
create policy "admin deletes tests" on public.tests for delete using (public.is_admin());
-- Questions: published test questions readable to students; admin full access.
create policy "questions read published or admin" on public.questions for select using (exists(select 1 from public.tests t where t.id=test_id and t.is_published) or public.is_admin());
create policy "admin inserts questions" on public.questions for insert with check (public.is_admin());
create policy "admin updates questions" on public.questions for update using (public.is_admin()) with check (public.is_admin());
create policy "admin deletes questions" on public.questions for delete using (public.is_admin());
-- Results: students see and insert only their own results; admin sees all.
create policy "results read own or admin" on public.results for select using (student_id=auth.uid() or public.is_admin());
create policy "students submit own result" on public.results for insert with check (student_id=auth.uid());
create policy "admin manages results" on public.results for delete using (public.is_admin());

-- IMPORTANT: After registering your intended admin account, find its UUID in
-- Authentication > Users. Replace ADMIN_UUID below and run this one-time command:
-- update public.profiles set role='admin' where id='ADMIN_UUID';
-- Note: this starter scores in browser. For high-stakes/exam-secure scoring,
-- move answer keys and grading to a trusted server/Edge Function.
