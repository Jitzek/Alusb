# IMPORTANT
Made for personal use, expect bugs and oversights

# Alusb

## DESCRIPTION
Persistent Arch Linux installation for USB

## MANUAL
### Step 1: Install git on installation medium
`pacman -Sy glibc git`<br>

### Step 2: Clone the base install branch of this repository
`git clone -b main --single-branch "https://github.com/Jitzek/Alusb.git"`

### Step 3: Make installation script executable
`chmod +x /path/to/Alusb/install-min.sh`

### Step 4: Execute installation script
`/path/to/Alusb/install-min.sh`

### Step 5 (After Base Install): Clone additional install branch of this repository and execute script
#### XFCE4:
1. `git clone -b xfce4 --single-branch "https://github.com/Jitzek/Alusb.git"`
2. `chmod +x /path/to/Alusb/install-xfce4.sh`
3. `/path/to/Alusb/install-min.sh`

#### GNOME:
1. `git clone -b gnome --single-branch "https://github.com/Jitzek/Alusb.git"`
2. `chmod +x /path/to/Alusb/install-gnome.sh`
3. `/path/to/Alusb/install-gnome.sh`

#### KDE:
1. `git clone -b kde --single-branch "https://github.com/Jitzek/Alusb.git"`
2. `chmod +x /path/to/Alusb/install-kde.sh`
3. `/path/to/Alusb/install-kde.sh`

