# CIS Microsoft Intune for Windows 11 Benchmark

## Level 1 (L1) - Corporate/Enterprise Environment (general use)

### Above Lock

#### **(L1) Ensure 'Allow Cortana Above Lock' is set to 'Block' (Automated)** 
**PolicyName:** CIS-L1-Enterprise-AboveLock-AllowCortana

**Description:** This policy setting determines whether or not the user can interact with Cortana using speech while the system is locked.

**Impact:** The system will need to be unlocked for the user to interact with Cortana using speech.

### Administrative Templates - Control Panel - Personalization
#### **(L1) Ensure 'Enable screen saver (User)' is set to 'Enabled' (Automated)**
**PolicyName:** 

**Description:** This policy setting enables the use of desktop screen savers.

**Impact:** A screen saver runs, provided that the following two conditions hold: First, a valid screen saver on the client is specified through the recommendation Force specific screen saver or through Control Panel on the client computer. Second, the recommendation Screen saver timeout setting is set to a nonzero value through the setting or through Control Panel.



## Level 2 (L2) - High Security/Sensitive Data Environment (limited functionality)




## BitLocker (BL)