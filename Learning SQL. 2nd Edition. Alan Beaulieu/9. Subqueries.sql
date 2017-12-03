SELECT
  account_id,
  product_cd,
  cust_id,
  avail_balance
FROM account
WHERE account_id = (SELECT MAX(account_id)
                    FROM account);

# ===== NONCORRELATED SUBQUERIES =====
# executed once prior to execution of the containing statement

# scalar subquery (returns a table comprising a single row and column)
SELECT
  account_id,
  product_cd,
  cust_id,
  avail_balance
FROM account
WHERE open_emp_id != (SELECT e.emp_id
                      FROM employee e INNER JOIN branch b
                          ON e.assigned_branch_id = b.branch_id
                      WHERE e.title = 'Head Teller' AND b.city = 'Woburn');

# IN operator
SELECT
  emp_id,
  fname,
  lname,
  title
FROM employee
WHERE emp_id IN (SELECT superior_emp_id
                 FROM employee);

# NOT IN operator
SELECT
  emp_id,
  fname,
  lname,
  title
FROM employee
WHERE emp_id NOT IN (SELECT superior_emp_id
                     FROM employee
                     WHERE superior_emp_id IS NOT NULL);

# comparison operator + ALL operator
SELECT
  emp_id,
  fname,
  lname,
  title
FROM employee
WHERE emp_id <> ALL (SELECT superior_emp_id
                     FROM employee
                     WHERE superior_emp_id IS NOT NULL);

# comparison operator + ALL operator
SELECT
  account_id,
  cust_id,
  product_cd,
  avail_balance
FROM account
WHERE avail_balance < ALL (SELECT a.avail_balance
                           FROM account a INNER JOIN individual i
                               ON a.cust_id = i.cust_id
                           WHERE i.fname = 'Frank' AND i.lname = 'Tucker');

# comparison operator + ANY operator
SELECT
  account_id,
  cust_id,
  product_cd,
  avail_balance
FROM account
WHERE avail_balance > ANY (SELECT a.avail_balance
                           FROM account a INNER JOIN individual i
                               ON a.cust_id = i.cust_id
                           WHERE i.fname = 'Frank' AND i.lname = 'Tucker');

# parentheses + IN operator
SELECT
  account_id,
  product_cd,
  cust_id
FROM account
WHERE (open_branch_id, open_emp_id) IN
      (SELECT
         b.branch_id,
         e.emp_id
       FROM branch b INNER JOIN employee e
           ON b.branch_id = e.assigned_branch_id
       WHERE b.name = 'Woburn Branch'
             AND (e.title = 'Teller' OR e.title = 'Head Teller'));

# ===== CORRELATED SUBQUERIES =====
# correlated subqueries are executed once for each candidate row

SELECT
  c.cust_id,
  c.cust_type_cd,
  c.city
FROM customer c
WHERE 2 = (SELECT COUNT(*)
           FROM account a
           WHERE a.cust_id = c.cust_id);

SELECT
  c.cust_id,
  c.cust_type_cd,
  c.city
FROM customer c
WHERE (SELECT SUM(a.avail_balance)
       FROM account a
       WHERE a.cust_id = c.cust_id)
BETWEEN 5000 AND 10000;

UPDATE account a
SET a.last_activity_date =
(SELECT MAX(t.txn_date)
 FROM transaction t
 WHERE t.account_id = a.account_id);
