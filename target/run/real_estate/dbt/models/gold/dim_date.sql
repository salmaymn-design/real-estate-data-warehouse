
  
    

create or replace transient table REAL_ESTATE_DB.GOLD.dim_date
    
    
    
    as (

SELECT

    ROW_NUMBER() OVER (ORDER BY listing_date) AS date_key,

    listing_date,

    YEAR(listing_date) AS year,
    MONTH(listing_date) AS month,
    DAY(listing_date) AS day,
    MONTHNAME(listing_date) AS month_name,
    DAYNAME(listing_date) AS day_name,
    QUARTER(listing_date) AS quarter

FROM REAL_ESTATE_DB.SILVER.listings_clean

WHERE listing_date IS NOT NULL
    )
;


  