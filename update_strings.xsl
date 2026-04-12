<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="shared_user_label"/>

    <xsl:template match="/resources">
        <resources>
            <xsl:copy-of select="*"/>
            <string name="shared_user_label">
                <xsl:value-of select="$shared_user_label"/>
            </string>
        </resources>
    </xsl:template>

</xsl:stylesheet>
