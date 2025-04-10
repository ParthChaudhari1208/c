/* REXX Program to verify account and generate card details with masked */

ADDRESS ISPEXEC "LIBDEF ISPPLIB DATASET ID('Z54734.PANELS')"
ADDRESS ISPEXEC 'DISPLAY PANEL(PANEL)'

ACCTNUM = STRIP(ACC)

IF ACCTNUM = '' THEN DO
    SAY 'Error: No account number entered.'
    EXIT 8
END

/* Define user ID and file names for input and output */
USERID = SYSVAR('SYSUID')
INFILE = "'Z54734.CUSTINFO'"
OUTFILE = "'Z54734.CARDINFO'"

/* Allocate and read the input file */
ADDRESS TSO "ALLOC F(INDD) DA("INFILE") SHR"
ADDRESS TSO "EXECIO * DISKR INDD (STEM LINES. FINIS)"
ADDRESS TSO "FREE F(INDD)"

IF LINES.0 = 0 THEN DO
    SAY 'Error: No records found in the input file.'
    EXIT 8
END

/* Initialize variables */
FOUND = 0

/* Loop to find the account */
DO I = 1 TO LINES.0
    PARSE VAR LINES.I NAME ACCT REST
    ACCT = STRIP(ACCT)

    IF ACCT = ACCTNUM THEN DO
        FOUND = 1
        LEAVE
    END
END

IF FOUND = 0 THEN DO
    SAY '** Account Number' ACCTNUM 'NOT FOUND in the database.'
    EXIT 8
END

/* Check if the card is already issued by reading cardinfo */
ADDRESS TSO "ALLOC F(CARDINDD) DA("OUTFILE") SHR"
ADDRESS TSO "EXECIO * DISKR CARDINDD (STEM CARDLINES. FINIS)"
ADDRESS TSO "FREE F(CARDINDD)"

IF CARDLINES.0 > 0 THEN DO
    DO I = 1 TO CARDLINES.0
        PARSE VAR CARDLINES.I CARD_ACCT CARD_NUM CARD_CVV CARD_EXP
        IF CARD_ACCT = ACCTNUM THEN DO
            SAY 'You already have an issued card. '
            EXIT 0
        END
    END
END

/* Generate Card Details */
SAY 'Account' ACCTNUM 'verified. Generating new card...'

CALL RANDOM
PART1 = RIGHT(RANDOM(1000, 9999), 4, 0)
PART2 = RIGHT(RANDOM(1000, 9999), 4, 0)
PART3 = RIGHT(RANDOM(1000, 9999), 4, 0)
PART4 = RIGHT(RANDOM(1000, 9999), 4, 0)
CARDNO = PART1 || PART2 || PART3 || PART4

CVV = RIGHT(RANDOM(100, 999), 3, 0)
EXPIRY = RIGHT(RANDOM(1, 12), 2, 0) || '/30'

MASKED_CARD = 'XXXX XXXX XXXX ' || RIGHT(CARDNO, 4)
MASKED_CVV = '***'

SAY 'Generated Card Details (Masked):'
SAY 'Card Number:' MASKED_CARD
SAY 'CVV:' MASKED_CVV
SAY 'Expiry Date:' EXPIRY

NEWREC.1 = ACCTNUM || ' ' || CARDNO || ' ' || CVV || ' ' || EXPIRY
NEWREC.0 = 1

ADDRESS TSO "ALLOC F(CARDDD) DA("OUTFILE") MOD REUSE"
ADDRESS TSO "EXECIO 1 DISKW CARDDD (STEM NEWREC. FINIS)"
ADDRESS TSO "FREE F(CARDDD)"

SAY '** Card Information successfully saved in ' OUTFILE

ADDRESS TSO
SUBMIT "'Z54734.JCL(SSHCMD)'"
SAY "JCL Submitted Successfully."
SAY "Commit changes 2nd time"

EXIT 0
