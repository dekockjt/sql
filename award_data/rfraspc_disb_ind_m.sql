-- select rfraspc_fund_code, rfraspc_aidy_code
-- from rfraspc
-- where rfraspc_aidy_code in ('2526', '2627')
-- and rfraspc_disburse_ind = 'M'
-- order by rfraspc_aidy_code;

select rfraspc_fund_code, rfraspc_aidy_code
from rfraspc
where rfraspc_disburse_ind = 'M'
order by rfraspc_aidy_code;