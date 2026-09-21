\# Banking Management System in MIPS



A simple \*\*Banking Management System\*\* made using \*\*MIPS Assembly Language\*\*. This project simulates basic banking operations such as checking balance, depositing money, withdrawing money, and transferring money between accounts.



\## Features



\* Login using \*\*CNIC and PIN\*\*

\* Check account balance

\* Deposit money

\* Withdraw money

\* Transfer money to another account

\* Check receiver account before transfer

\* Prevent transfer to your own account

\* Check insufficient balance

\* Set transaction limits

\* Handle invalid and negative inputs

\* Save updated account information in a text file

\* Allow only \*\*3 wrong PIN attempts\*\*



\## Technologies Used



\* \*\*MIPS Assembly Language\*\*

\* \*\*MARS MIPS Simulator\*\*

\* \*\*Text File (`Accounts.txt`)\*\*



\## Project Files



```text

Banking-Management-System-in-MIPS/

│

├── Bank.asm

├── Accounts.txt

```



\### Bank.asm



This is the main MIPS Assembly program. It contains the login system, banking operations, input validation, file handling, and menu system.



\### Accounts.txt



This file stores the account information. The account data contains:



```text

CNIC PIN Balance

```



\## Main Menu



After successful login, the user gets the following menu:



```text

Main Menu:

1\. Check Balance

2\. Withdraw

3\. Deposit

4\. Funds Transfer

5\. Exit

```



\## How It Works



\### 1. Login



The program first reads account information from `Accounts.txt`.



The user enters:



\* CNIC

\* PIN



If the CNIC is not found, the program asks again.

If the PIN is incorrect, the user can try again. After \*\*3 incorrect PIN attempts\*\*, the program exits.



\### 2. Check Balance



The user can select \*\*Check Balance\*\* to see the current account balance.



\### 3. Withdraw Money



The user enters the amount they want to withdraw.

The program checks:



\* The amount is not negative

\* The amount is at least 500

\* The amount does not exceed 50,000

\* The account has enough balance



If everything is correct, the amount is removed from the account balance.



\### 4. Deposit Money



The user can add money to their account.

The program checks:



\* The amount is not negative

\* The amount is at least 500

\* The deposit does not exceed 50,000



After a successful deposit, the new balance is shown.



\### 5. Funds Transfer



The user can transfer money to another account.

The program checks:



\* Receiver CNIC exists

\* Receiver is not the same as the sender

\* Amount is not negative

\* Amount is at least 500

\* Transfer amount does not exceed 50,000

\* Sender has enough balance



If all checks pass, the sender's balance is reduced and the receiver's balance is increased.



\### 6. Save and Exit



When the user selects \*\*Exit\*\*, the updated account information is written back to `Accounts.txt`. The program then closes the file and exits.



\## How to Run



1\. Download or clone this repository.

2\. Open \*\*MARS MIPS Simulator\*\*.

3\. Open `Bank.asm`.

4\. Make sure `Accounts.txt` is available at the file path used in the program.

5\. Assemble the program.

6\. Run the program.

7\. Enter a valid CNIC and PIN from `Accounts.txt`.



> \*\*Note:\*\* The current program contains a file path inside `Bank.asm`. If you move the project to another computer or folder, update the file path in the `.data` section.



\## Example Account File



The account file follows this format:



```text

CNIC PIN Balance

```



For example:



```text

12345 1234 10000

23456 5678 15000

34567 4321 20000

```



\## Learning Objectives



This project helps in understanding:



\* MIPS Assembly Language

\* Registers

\* Loops and branches

\* Arrays

\* Procedures/Subroutines

\* System calls

\* File handling

\* User input

\* Data validation

\* Basic banking logic



\## Conclusion



The Banking Management System in MIPS is a simple project that shows how basic banking operations can be implemented using Assembly Language. It uses file handling to read and save account information and provides different banking operations through a simple menu.



\## Author



\*\*Zohaib Aftab\*\*

