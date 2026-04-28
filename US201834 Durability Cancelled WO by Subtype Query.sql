SELECT
    dh."Cur_Area_Nbr" || '-' || dh."Cur_Area_Nm"  AS "Area",
    dh."Cur_BU_Nbr"   || '-' || dh."Cur_BU_Desc"  AS "Business Unit",
    wom."Div_Nbr"     || '-' || dh."Cur_Div_Nm"   AS "Division",

    COUNT(DISTINCT CASE WHEN wom."Work_Order_Status_Nm" = 'Completed'
                        THEN wom."Work_Order_Nbr" END)                    AS "Completed",
    COUNT(DISTINCT CASE WHEN wom."Work_Order_Status_Nm" = 'Pending P-Card Completion'
                        THEN wom."Work_Order_Nbr" END)                    AS "Pending P-Card Completion",
    COUNT(DISTINCT CASE WHEN wom."Work_Order_Status_Nm" = 'Pending QCI'
                        THEN wom."Work_Order_Nbr" END)                    AS "Pending QCI",
    COUNT(DISTINCT CASE WHEN wom."Work_Order_Status_Nm" = 'Closed'
                        THEN wom."Work_Order_Nbr" END)                    AS "Closed",
       case when 
        COUNT(DISTINCT CASE WHEN wom."Work_Order_Status_Nm" = 'Closed'
                            THEN wom."Work_Order_Nbr" END) > 0 then 
     
   COUNT(DISTINCT CASE WHEN wom."Work_Order_Status_Nm" = 'Closed' THEN wom."Work_Order_Nbr" END) /
     COUNT(DISTINCT CASE WHEN wom."Work_Order_Status_Nm" IN (
                                    'Closed', 'Completed',
                                    'Pending P-Card Completion', 'Pending QCI')
                            THEN wom."Work_Order_Nbr" END) * 100 else 100 end AS "Closed of Completed %",
                            COUNT(DISTINCT CASE WHEN wom."Work_Order_Status_Nm" = 'Completed'
                        THEN wom."Work_Order_Nbr" END)
    + COUNT(DISTINCT CASE WHEN wom."Work_Order_Status_Nm" = 'Pending P-Card Completion'
                          THEN wom."Work_Order_Nbr" END)
    + COUNT(DISTINCT CASE WHEN wom."Work_Order_Status_Nm" = 'Pending QCI'
                          THEN wom."Work_Order_Nbr" END)
    + COUNT(DISTINCT CASE WHEN wom."Work_Order_Status_Nm" = 'Closed'
                          THEN wom."Work_Order_Nbr" END)                   AS "WO Total"
                                                       

FROM "Eam_Work_Order_Metrics" wom
INNER JOIN (
    SELECT DISTINCT
           "Cur_Div_Nbr",
           "Cur_Div_Nm",
           "Cur_BU_Nbr",
           "Cur_BU_Desc",
           "Cur_Area_Nbr",
           "Cur_Area_Nm"
    FROM "Dim_Corp_Hier"
    WHERE "Is_Current" = TRUE
   and "Cur_Div_Nbr" in (3430,4691,4692,4174,4581)
) dh
ON CAST(wom."Div_Nbr" AS DECIMAL) = dh."Cur_Div_Nbr"

WHERE UPPER(wom."Asset_Nbr") LIKE '%PARENT%'
  AND UPPER(wom."Status") NOT IN ('SOLD', 'SALVAGE')
  AND wom."Work_Order_Status_Nm" IN ('Completed', 'Pending P-Card Completion', 'Pending QCI', 'Closed')
  AND CAST(wom."Actual_Completion_Dt" AS DATE) BETWEEN '2026-01-25' AND '2026-02-07'

GROUP BY
    dh."Cur_Area_Nbr" || '-' || dh."Cur_Area_Nm",
    dh."Cur_BU_Nbr"   || '-' || dh."Cur_BU_Desc",
    wom."Div_Nbr"     || '-' || dh."Cur_Div_Nm"

order by  wom."Div_Nbr"     || '-' || dh."Cur_Div_Nm" 