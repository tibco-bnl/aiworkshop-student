# Adding a Keyboard Layout to XFCE

This document describes how to add an additional keyboard layout for all
users on an Ubuntu 24 server using XFCE and RDP.

## 1. Edit the Global Keyboard Configuration

Open the global XFCE keyboard layout configuration:

``` bash
sudo nano /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml
```

## 2. Add the Keyboard Layout

Update the `XkbLayout` property.

For example:

``` xml
<property name="XkbLayout" type="string" value="gb,fr,pt,it"/>
```

The **first layout in the list is the default layout**. In this example,
the default keyboard layout is English (UK).

  Code   Keyboard Layout
  ------ -----------------------
  `gb`   English (UK)
  `fr`   French
  `pt`   Portuguese (Portugal)
  `it`   Italian

To add German (`de`), for example:

``` xml
<property name="XkbLayout" type="string" value="gb,fr,pt,it,de"/>
```

## 3. Update the Variant List

The `XkbVariant` property must contain a matching entry for each
keyboard layout.

If no special variants are used, leave the entries empty.

For five layouts:

``` xml
<property name="XkbVariant" type="string" value=",,,,"/>
```

## 4. Example Global Configuration

``` xml
<?xml version="1.0" encoding="UTF-8"?>

<channel name="keyboard-layout" version="1.0">
  <property name="Default" type="empty">
    <property name="XkbDisable" type="bool" value="false"/>
    <property name="XkbLayout" type="string" value="gb,fr,pt,it,de"/>
    <property name="XkbVariant" type="string" value=",,,,"/>
    <property name="XkbModel" type="string" value="pc105"/>
    <property name="XkbOptions" type="string" value="grp:alt_shift_toggle"/>
  </property>
</channel>
```

The following line:

``` xml
<property name="Default" type="empty">
```

is an XFCE configuration group. It does **not** define the default
keyboard layout.

The first entry in `XkbLayout` determines the initial/default layout:

``` xml
value="gb,fr,pt,it,de"
```

In this example, `gb` is the default.

## 5. Apply the Configuration

Users must completely log out of their XFCE/RDP session and reconnect.

For existing users, XFCE may already have stored keyboard settings in
the user's configuration.

Check for keyboard-related configuration files:

``` bash
find ~/.config/xfce4 \( -iname '*keyboard*' -o -iname '*xkb*' \)
```

On this environment, the user keyboard configuration is stored in:

``` text
~/.config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml
```

Before making changes, create a backup:

``` bash
cp ~/.config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml \
   ~/.config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml.backup
```

To reset the user's stored keyboard configuration:

``` bash
rm ~/.config/xfce4/xfconf/xfce-perchannel-xml/keyboards.xml
```

Then completely log out of the XFCE/RDP session and reconnect.

The global configuration from
`/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/keyboard-layout.xml` should
then be applied.

## 6. Select a Keyboard Layout

Use the **Keyboard Layouts** indicator in the XFCE panel to select the
required keyboard layout.

The user can switch between the configured layouts, for example:

``` text
GB → FR → PT → IT → DE
```

The configured keyboard shortcut is:

``` text
Alt + Shift
```

## 7. Set the Layout Policy to Global

Right-click the **Keyboard Layouts** indicator in the XFCE panel and
select **Properties**.

Set **Layout Policy** to:

``` text
Global
```

This ensures that the selected keyboard layout remains active when
opening or switching applications.

If the policy is set to **Per Window** or **Per Application**, XFCE may
appear to switch back to the default keyboard layout when opening
another application.

## Common XKB Layout Codes

  Code   Keyboard Layout
  ------ -----------------------
  `us`   English (US)
  `gb`   English (UK)
  `fr`   French
  `de`   German
  `nl`   Dutch
  `pt`   Portuguese (Portugal)
  `br`   Portuguese (Brazil)
  `it`   Italian
  `es`   Spanish
  `be`   Belgian
