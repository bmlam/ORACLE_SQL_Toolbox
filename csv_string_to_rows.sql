-- demonstrate how to convert a comma separated string of elements into a set of rows
-- the separator can be changed from comma to anything suitable
-- this hack is inspired by the example of Connor McDonald on DevGym.oracle.com website
-- but meant to be easier to understandd and customize.
--
-- On purpose I use a few more common table expressions than absolutely necessary - 
-- Connors version can be converted to use only one CTE, plus a somehow magical
-- CROSS JOIN 
--
-- Note 1: a more procedural approach to solve the problem might perform better but the 
-- main purpose of this demo is to show how versatile / powerful pure SQL can be.
--
WITH src0_ AS (
    SELECT
        'ab,123,banana,x1z' csv,
        ',' AS sep
    FROM
        dual
),src1_ AS (
    SELECT DISTINCT -- this keyword is vital to make LAG() emit the proper value
        instr(csv
        || /* make sure INSTR() will return a hit at least once */ sep,sep,level) sep_pos,
        csv
    FROM
        src0_
    CONNECT BY
    -- we could say level <= length( csv ), but that would cause CONNECT BY LEVEL to be unnecesarily high
--        level <= length(csv) + /* for the appended separator */ 1
        level <= length(replace(csv,sep,'') ) + /* for the appended separator */ 1
),src2_ AS (
    SELECT
        csv,
        LAG(sep_pos) OVER(
            PARTITION BY NULL
            ORDER BY
                sep_pos
        ) + 1 elem_start_at,
        sep_pos elem_end_at
    FROM
        src1_
),src3_ AS (
    SELECT
        src2_.*,
        nvl(elem_start_at,1) substr_from,
        elem_end_at - nvl(elem_start_at,1) substr_len
    FROM
        src2_
    WHERE
        1 = 1
        AND   nvl(elem_start_at,-1) <> nvl(elem_end_at,-1)
) SELECT
    src3_.*,
    substr(csv,substr_from,substr_len) elem
  FROM
    src3_;