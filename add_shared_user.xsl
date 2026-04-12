<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:android="http://schemas.android.com/apk/res/android">

    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="shared_user_label"/>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="/manifest">
        <manifest>
            <xsl:apply-templates select="@*"/>
            <xsl:attribute name="android:sharedUserId">com.termux.nix</xsl:attribute>
            <xsl:attribute name="android:sharedUserLabel">@string/shared_user_label</xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </manifest>
    </xsl:template>

</xsl:stylesheet>
