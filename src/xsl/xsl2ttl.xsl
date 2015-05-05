<!--
#3> <> prov:specializationOf <https://github.com/timrdf/pvcs/blob/master/src/xsl/xsl2ttl.xsl>
#3>    prov:wasDerivedFrom <https://github.com/timrdf/csv2rdf4lod-automation/wiki/SDV-organization>,
#3>                        <https://github.com/timrdf/csv2rdf4lod-automation/wiki/Alternative-XML-to-RDF-converters#xsl-crib-sheet>;
#3> .
-->
<xsl:transform version="2.0" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="">
<xsl:output method="text"/>

<!--xsl:param name="trim-base"     select="'src/main/xsl/info/kwarc/krextor/'"/-->
<xsl:param name="trim-base"        select="'/source/'"/>
<xsl:param name="package-preamble" select="''"/> <!-- e.g. '/projects/krextor/' -->
<xsl:param name="cr-base-uri"      select="'http://my.com'"/>
<xsl:param name="cr-source-id"     select="'epa-gov'"/>
<xsl:param name="cr-dataset-id"    select="'some-dataset'"/>
<xsl:param name="cr-version-id"    select="'latest'"/>
<xsl:param name="cr-portion-id"    select="''"/> <!-- serves as the svn 'revision id' -->

<xsl:variable name="s"        select="concat($cr-base-uri, if(string-length($cr-source-id))  then concat('/source/', $cr-source-id)     else '')"/>
<xsl:variable name="abstract" select="concat($cr-base-uri,'/source/',$cr-source-id,'/dataset/',$cr-dataset-id)"/>
<xsl:variable name="sd"       select="concat($s,           if(string-length($cr-dataset-id)) then concat('/dataset/',$cr-dataset-id,'/') else '')"/>
<xsl:variable name="sdv"      select="concat($cr-base-uri,'/source/',$cr-source-id,'/dataset/',$cr-dataset-id,'/version/',$cr-version-id)"/>
<xsl:variable name="sdv_"     select="concat($sd,          if(string-length($cr-version-id)) then concat('version/', $cr-version-id)     else '')"/>

<xsl:variable name="prefixes">
<xsl:text><![CDATA[@prefix prov:    <http://www.w3.org/ns/prov#>.
@prefix dcterms: <http://purl.org/dc/terms/>.
@prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#>.
@prefix foaf:    <http://xmlns.com/foaf/0.1/>.
@prefix pext:    <http://www.ontotext.com/proton/protonext#> .
@prefix xsl:     <http://www.w3.org/1999/XSL/Transform#> .

]]></xsl:text>
</xsl:variable>

<xsl:variable name="xsl-absolute-filepath" select="document-uri(/)"/>
<xsl:variable name="xsl-local"             select="reverse(tokenize(document-uri(/),'/'))[1]"/>
<xsl:variable name="xsl-in-package"        select="concat($package-preamble,replace(document-uri(/),concat('^.*',$trim-base),''))"/>

<!-- Note that this variable aligns with https://github.com/timrdf/pvcs/blob/master/src/xsl/svn2prov.xsl#L108 -->
<xsl:variable name="revisionless" select="concat($sdv,'/',$package-preamble,replace(document-uri(/),concat('^.*',$trim-base),''))"/>
<!-- Note that this variable aligns with https://github.com/timrdf/pvcs/blob/master/src/xsl/svn2prov.xsl#L109 -->
<xsl:variable name="revision"     select="concat($sdv,'/revision/',$cr-portion-id,'/',$package-preamble,replace(document-uri(/),concat('^.*',$trim-base),''))"/>

<xsl:variable name="revisionless-dir" select="replace($revisionless,'/[^/]*$','/')"/>

<xsl:template match="/">
   <xsl:value-of select="concat('@base &lt;',$revisionless,'/&gt; .',$NL,$prefixes)"/>

   <xsl:value-of select="concat('# absolute file path | ',$xsl-absolute-filepath,$NL)"/>
   <xsl:value-of select="concat('# xsl-local          |                                                                                                                                                           ',$xsl-local,$NL)"/>
   <xsl:value-of select="concat('# package preamble   |                                                                                                                   ',$package-preamble,$NL)"/>
   <xsl:value-of select="concat('# xsl-in-package     |                                                                                                                   ',$xsl-in-package,$NL)"/>
   <xsl:value-of select="concat('# trim-base          |                                                                                                                            ',$trim-base,$NL)"/>
   <!--
       When file:
                                                                                                                      source/trunk/src/xslt/generic/generic.xsl
          prov2svn identifies a revision as e.g.:
      
       <http://mydomain.com/source/kwarc-info-krextor/dataset/svn/version/2015-May-04/revision/2157/projects/krextor/trunk/src/xslt/generic/generic.xsl>
      
             which is a specialization of:
      
       <http://mydomain.com/source/kwarc-info-krextor/dataset/svn/version/2015-May-04/projects/krextor/trunk/src/xslt/generic/generic.xsl>
      
                which is a specialization of:
                                                                                                     <java:.projects.krextor.trunk.src.xslt.generic.generic.xsl>
   -->
   <xsl:value-of select="concat('#  - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -',$NL)"/>
   <xsl:value-of select="concat('# baseURI            |               ',$cr-base-uri,$NL)"/>
   <xsl:value-of select="concat('# /sd                |               ',$abstract,$NL)"/>
   <xsl:value-of select="concat('# /sdv               |               ',$sdv,$NL)"/>
   <xsl:value-of select="concat('# revisioned target  |               http://mydomain.com/source/kwarc-info-krextor/dataset/svn/version/2015-May-04/revision/2157/projects/krextor/trunk/src/xslt/generic/generic.xsl',$NL)"/>
   <xsl:value-of select="concat('# $revision          |               ',$revision,$NL)"/>
   <xsl:value-of select="concat('# no rev target      |               http://mydomain.com/source/kwarc-info-krextor/dataset/svn/version/2015-May-04/projects/krextor/trunk/src/xslt/generic/generic.xsl',$NL)"/>
   <xsl:value-of select="concat('# $revisionless      |               ',$revisionless,$NL)"/>


   <xsl:value-of select="concat($NL,'&lt;',$revisionless,'&gt;',$NL,
                               '   a &lt;',namespace-uri(*[1]),'#',upper-case(substring(local-name(*[1]),1,1)),substring(local-name(*[1]), 2),'&gt;;',$NL)"/>
   <xsl:value-of select="concat('',$NL)"/>
   <xsl:apply-templates select="//xsl:import" mode="referenced"/>
   <xsl:value-of select="concat('',$NL)"/>
   <xsl:apply-templates select="//xsl:template" mode="referenced"/>
   <xsl:value-of select="concat('.',$NL)"/>

   <xsl:apply-templates select="//xsl:template" mode="describe"/>
</xsl:template>

<xsl:template match="xsl:import">
   <xsl:value-of select="concat('   xsl:import &lt;',@href,'&gt;;',$NL)"/>
</xsl:template>

<xsl:template match="xsl:template[@name]" mode="referenced">
   <!-- <stylesheet xmlns:krextor="http://kwarc.info/projects/krextor" -->
   <xsl:variable name="prefix" select="substring-before(@name,':')"/>
   <xsl:variable name="local"  select="substring-after(@name,':')"/>
   <xsl:variable name="ns"     select="namespace-uri-for-prefix($prefix,.)"/>
   <xsl:value-of select="concat('   xsl:template &lt;',$ns,'/',$local,'&gt;;',$NL)"/>
</xsl:template>

<xsl:template match="xsl:template[@name]" mode="describe">
   <xsl:variable name="prefix" select="substring-before(@name,':')"/>
   <xsl:variable name="local"  select="substring-after(@name,':')"/>
   <xsl:variable name="ns"     select="namespace-uri-for-prefix($prefix,.)"/>
   <xsl:value-of select="concat('&lt;',$ns,'/',$local,'&gt;',$NL,
                                '   a xsl:Template;',$NL)"/>
   <xsl:apply-templates select=".//xsl:call-template" mode="calls"/>
   <xsl:value-of select="concat('.',$NL)"/>
</xsl:template>

<xsl:template match="xsl:template[not(@name)]" mode="referenced">
   <xsl:value-of select="concat('   xsl:template &lt;template/',position(),'&gt;;',$NL)"/>
</xsl:template>

<xsl:template match="xsl:template[not(@name)]" mode="describe">
   <xsl:value-of select="concat('&lt;','template/',position(),'&gt;',$NL,
                                '   a xsl:Template;',$NL,
                                if (@match) then concat('   xsl:match ',$DQ,@match,$DQ,';',$NL) else '')"/>
   <xsl:apply-templates select=".//xsl:call-template" mode="calls"/>

   <xsl:value-of select="concat('.',$NL)"/>
</xsl:template>

<xsl:template match="xsl:call-template" mode="calls">
   <xsl:variable name="prefix" select="substring-before(@name,':')"/>
   <xsl:variable name="local"  select="substring-after(@name,':')"/>
   <xsl:variable name="ns"     select="namespace-uri-for-prefix($prefix,.)"/>
   <xsl:value-of select="concat('   xsl:call-template &lt;',$ns,'/',$local,'&gt;;',$NL)"/>
</xsl:template>

<!--xsl:template match="@*|node()">
  <xsl:copy>
      <xsl:copy-of select="@*"/>   
      <xsl:apply-templates/>
  </xsl:copy>
</xsl:template-->

<!--xsl:template match="text()">
   <xsl:value-of select="normalize-space(.)"/>
</xsl:template-->

<xsl:variable name="NL" select="'&#xa;'"/>
<xsl:variable name="DQ" select="'&#x22;'"/>

</xsl:transform>
