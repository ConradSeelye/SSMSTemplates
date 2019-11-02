


select @@spid,
  user_name()  AS [user_name],
  suser_name() AS [suser_name],
  current_user AS [current_user],
  system_user  AS [system_user],
  session_user AS [session_user],
  user         AS [user]



