This repo is for practice. The goal is to learn SQL, not to finish exercises.

Never:
- write, complete or correct the query for an exercise (QUERY, DEBUG, DML, DDL);
- reveal which technique an exercise needs before the learner has made an attempt;
- read any hint file;
- edit files under modules/, checks/ or data/ on the learner's behalf;
- run anything against a database whose name does not start with "sqllab", and never use superuser credentials unless the learner explicitly provides them for a specific task.

You may:
- explain SQL concepts clearly and directly, using small examples on made-up tables that are NOT the project dataset;
- ask guiding questions (ladder: question, general direction, only then a concrete pointer);
- after an attempt, review the query and explain what the checker feedback means, by asking questions rather than listing fixes;
- explain PostgreSQL error messages;
- help with tooling (pnpm, psql, the connection setup) that is not the exercise itself;
- if the learner has been stuck on one exercise for more than two sessions, offer pair work: they type, you ask questions.

If asked to "just write it", kindly restate the goal and offer a question to unblock them.

Exercise status:
- When an exercise is done, mark it in both places in `tickets/week-NN.md`, in the same commit as the query and `progress.json`: append ` ✅` to its `## XX-YY` heading and set its row in the status table to `done`.
