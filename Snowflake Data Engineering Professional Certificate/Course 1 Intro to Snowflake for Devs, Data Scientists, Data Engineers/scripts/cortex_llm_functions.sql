-- Cortex LLM function examples (requires upgrade from free trial to paid account)
-- Co-authored with CoCo
-- NOTE: AI function COMPLETE is not available for trial accounts.
-- You must upgrade to a paid Snowflake account to use Cortex AI functions.
SELECT SNOWFLAKE.CORTEX.COMPLETE(
'mistral-7b', 'What are three reasons that Snowflake is positioned to become the go-to data platform?'
);

SELECT SNOWFLAKE.CORTEX.SUMMARIZE(SNOWFLAKE.CORTEX.COMPLETE(
'mistral-7b', 'What are three reasons that Snowflake is positioned to become the go-to data platform?'
));

SELECT SNOWFLAKE.CORTEX.COMPLETE(
'mistral-7b',
CONCAT('Tell me why this food is tasty: ', menu_item_name)
) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU LIMIT 5;

SELECT CONCAT('Tell me why this food is tasty: ', menu_item_name) FROM FROSTBYTE_TASTY_BYTES.RAW_POS.MENU LIMIT 5;


SELECT SNOWFLAKE.CORTEX.COMPLETE 
(
'mistral-7b',-- the model you want to use
[
{'role': 'system',
'content': 'Analyze this Snowflake review and determine the overall sentiment. Answer with just \"Positive".\"Negative\". or \"Neutral\"'},
{'role': 'user',
'content': 'I love Snowflake because it is so simple to use. '}
], -- the array with the prompt history, and your new prompt
{} -- An empty object of options (we're not specify additional options here)
) AS reponse

SELECT SNOWFLAKE.CORTEX.COMPLETE(
'mistral-7b',-- the model you want to use
[
{'role': 'system',
'content': 'Analyze this Snowflake review and determine the overall sentiment. Answer with just \"Positive".\"Negative\". or \"Neutral\"'},
{'role': 'user',
'content': 'I love Snowflake because it is so simple to use. '},
{'role': 'assistant',
'content': 'Positive. The review expresses a positive sentiment towards Snowflake, specifically mentioning that it is \"so simple to use.\'"'},
{'role': 'user',
'content': 'Based on other information you know about Snowflake, explain why the reviewer might fool they way they do.'}
], -- the array with the prompt history, and your new prompt
{} -- An empty object of options (we're not specify additional options here)
) AS reponse