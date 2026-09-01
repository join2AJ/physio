-- ============================================================
--  SAMPLE DATA - approx 50 physiotherapy visits across past dates.
--  Run in: Supabase -> SQL Editor -> New query -> paste -> Run.
--  Rows attach to YOUR account (looked up by the email below).
--  >>> Change the email if you log in with a different one.
--  To remove ALL visit rows later (e.g. before real use), run:
--      delete from public.visits;
-- ============================================================
with u as (
  select id from auth.users
  where email = 'join2ajkumar@gmail.com'      -- <-- your login email
  limit 1
)
insert into public.visits (id, user_id, date, patient_name, status, amount, diagnosis, reason)
select gen_random_uuid()::text, u.id, d.date, d.name, d.status, d.amount, d.diagnosis, d.reason
from u, (values
    ('2026-05-01','Kavita Joshi','Neck pain','Completed',600,null),
    ('2026-05-02','Lakshmi Iyer','Sciatica','Completed',700,null),
    ('2026-05-03','Ramesh Kumar','Lower back pain','Completed',450,null),
    ('2026-05-03','Deepa Menon','Plantar fasciitis','Not completed',null,'Payment pending'),
    ('2026-05-07','Suresh Rao','Rotator cuff injury','Completed',500,null),
    ('2026-05-12','Ramesh Kumar','Lower back pain','Completed',450,null),
    ('2026-05-12','Deepa Menon','Plantar fasciitis','Completed',700,null),
    ('2026-05-13','Neha Kapoor','Frozen shoulder','Completed',600,null),
    ('2026-05-17','Ramesh Kumar','Lower back pain','Completed',650,null),
    ('2026-05-19','Arjun Reddy','Sports injury (ACL)','Not completed',null,'Patient unwell'),
    ('2026-05-23','Suresh Rao','Rotator cuff injury','Completed',500,null),
    ('2026-05-25','Suresh Rao','Rotator cuff injury','Completed',600,null),
    ('2026-05-27','Neha Kapoor','Frozen shoulder','Not completed',null,'Payment pending'),
    ('2026-06-01','Pooja Desai','Knee osteoarthritis','Completed',550,null),
    ('2026-06-01','Anjali Gupta','Post-surgery rehab','Completed',500,null),
    ('2026-06-03','Priya Nair','Cervical spondylosis','Completed',550,null),
    ('2026-06-03','Rajesh Patel','Lower back pain','Completed',600,null),
    ('2026-06-04','Amit Verma','Sprained ankle','Completed',500,null),
    ('2026-06-05','Anjali Gupta','Post-surgery rehab','Completed',600,null),
    ('2026-06-06','Farhan Khan','Sciatica','Completed',450,null),
    ('2026-06-10','Arjun Reddy','Sports injury (ACL)','Completed',650,null),
    ('2026-06-12','Arjun Reddy','Sports injury (ACL)','Completed',700,null),
    ('2026-06-13','Vikram Singh','Tennis elbow','Completed',650,null),
    ('2026-06-13','Ramesh Kumar','Lower back pain','Not completed',null,'Family emergency'),
    ('2026-06-14','Pooja Desai','Knee osteoarthritis','Completed',500,null),
    ('2026-06-16','Amit Verma','Sprained ankle','Completed',400,null),
    ('2026-06-16','Farhan Khan','Sciatica','Completed',400,null),
    ('2026-06-20','Ganesh Iyer','Stroke rehabilitation','Completed',500,null),
    ('2026-06-20','Deepa Menon','Plantar fasciitis','Completed',550,null),
    ('2026-06-21','Sunita Sharma','Frozen shoulder','Completed',400,null),
    ('2026-07-05','Suresh Rao','Rotator cuff injury','Completed',500,null),
    ('2026-07-05','Mohammed Ali','Knee osteoarthritis','Completed',600,null),
    ('2026-07-12','Deepa Menon','Plantar fasciitis','Not completed',null,'Patient unwell'),
    ('2026-07-16','Kavita Joshi','Neck pain','Completed',600,null),
    ('2026-07-16','Deepa Menon','Plantar fasciitis','Completed',550,null),
    ('2026-07-17','Suresh Rao','Rotator cuff injury','Completed',650,null),
    ('2026-07-17','Pooja Desai','Knee osteoarthritis','Completed',400,null),
    ('2026-07-18','Arjun Reddy','Sports injury (ACL)','Completed',700,null),
    ('2026-07-21','Suresh Rao','Rotator cuff injury','Completed',500,null),
    ('2026-07-26','Neha Kapoor','Frozen shoulder','Completed',400,null),
    ('2026-08-03','Lakshmi Iyer','Sciatica','Not completed',null,'Payment pending'),
    ('2026-08-05','Arjun Reddy','Sports injury (ACL)','Completed',500,null),
    ('2026-08-11','Priya Nair','Cervical spondylosis','Not completed',null,'Payment pending'),
    ('2026-08-12','Kavita Joshi','Neck pain','Completed',600,null),
    ('2026-08-13','Rajesh Patel','Lower back pain','Not completed',null,'Rescheduled by patient'),
    ('2026-08-18','Meera Pillai','Cervical spondylosis','Completed',500,null),
    ('2026-08-19','Lakshmi Iyer','Sciatica','Completed',450,null),
    ('2026-08-22','Ganesh Iyer','Stroke rehabilitation','Completed',500,null),
    ('2026-08-23','Lakshmi Iyer','Sciatica','Completed',500,null),
    ('2026-08-27','Anjali Gupta','Post-surgery rehab','Completed',400,null)
) as d(date, name, diagnosis, status, amount, reason);
