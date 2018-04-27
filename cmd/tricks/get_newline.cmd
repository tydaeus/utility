@Echo Off
:: retrieves the newline characters for use in variables
:: see https://stackoverflow.com/questions/6379619/explain-how-dos-batch-newline-variable-hack-works for explanation


:: define #NL for use without delayed expansion
:: skip if already defined
:DEFINE_NON_DELAYED
if defined #NL goto :DEFINE_DELAYED

setLocal

:: note that two blank lines are required, first for capturing the newline
set NLM=^


endLocal & set #NL=^^^%NLM%%NLM%^%NLM%%NLM%

:: definition for use with delayed expansion
:DEFINE_DELAYED
if defined #DL goto :END

(set #DL=^
%=EMPTY=%
)

:END