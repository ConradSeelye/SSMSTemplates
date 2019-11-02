
/*
View Login permissions
date: 4/22/2019
source: https://dba.stackexchange.com/questions/235314/finding-all-users-with-access-to-a-table-in-sql-server

*/


select  princ.name
,       princ.type_desc
,       perm.permission_name
,       perm.state_desc
,       perm.class_desc
,       object_name(perm.major_id)
from    sys.database_principals princ
left join
        sys.database_permissions perm
on      perm.grantee_principal_id = princ.principal_id

