THODA SA TU, THODA SA MAIN — V4 ♡

Updates:
- Homepage photo crop shifted right and upward to preserve Aastha's head and reduce empty space above.
- Home text is slightly more compact and lower to reduce overlap with faces.
- Gallery photos open in a full-screen viewer.
- Swipe left/right on mobile, use arrows on any device, or press Escape to close.
- Photo counter included.

Preview:
Open `index.html` locally, keeping the `assets/` folder beside it.

Vercel:
Deploy `index.html` and the entire `assets/` folder together. No build command needed.

Live hugs and kisses:

1. Create a free Supabase project and run [`supabase-reactions.sql`](supabase-reactions.sql) in its SQL Editor.
2. In Supabase Dashboard → Connect, copy the project URL and **publishable** key into `supabase-config.js`.
3. Deploy `index.html`, `assets/`, and `supabase-config.js` to Vercel together.

Both phones will immediately see the same live hug and kiss totals. The setup intentionally stores only each reaction type and its timestamp. Do not put a Supabase `service_role` or secret key in the browser config file.

Daily task answers:

Run the complete `supabase-reactions.sql` file. The daily task uses the October 20 to November 23 trip window, shows one prompt per calendar day, and stores one answer for each participant (`Keshav` and `Aastha`) per day. Only the current day is shown in the page; previous answers remain in the `daily_answers` table.
