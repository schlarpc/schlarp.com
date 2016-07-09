+++
date = "2014-03-21T00:00:00-00:00"
draft = false
title = "Steam Emotifier"
+++

_(Note: currently not wired up on this new site. Will be fixed soon.)_

<form method="POST" enctype="multipart/form-data">
    <label>
        Image to convert:
        <input type="file" name="image" />
    </label>
    <label>
        Your Steam community ID
        <input type="text" name="user" />
    </label>
    <label>
        Blend color (advanced)
        <input type="text" value="#000000" name="blend" />
    </label>
    <label>
        Emote name weight (advanced)
        <input type="text" value="0" name="weight" />
    </label>
    <label>
        <input type="submit" disabled="disabled" value="Convert" />
    </label>
</form>


## What is this?

This tool converts small (32x32 or less) images into arrays of emotes on Steam based on the ones
you own. Select an image file, enter your community ID (AKA custom URL, e.g. if your profile is
steamcommunity.com/id/whatever then your ID is "whatever"), and submit to get the closest color
match to your image.

If you want to change what the transparent pixels in the emotes should be set to, change the blend
color to a valid hex code. If you need the result to be shorter in terms of characters, you can add
weight to the emote names. This will degrade picture quality but will make the output smaller.

Make sure your Steam inventory is set to public in your privacy settings or this won't work properly.

