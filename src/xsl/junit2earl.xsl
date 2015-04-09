<!--
#3> <> prov:specializationOf <https://github.com/timrdf/pvcs/blob/master/src/xsl/svn2prov.xsl>;
#3>    prov:wasDerivedFrom   <https://github.com/timrdf/csv2rdf4lod-automation/wiki/SDV-organization>;
#3>    prov:wasDerivedFrom   <http://www.w3.org/ns/earl#>;
#3>    prov:wasDerivedFrom   <http://www.w3.org/ns/prov#>;
#3>    prov:wasDerivedFrom   <https://github.com/timrdf/pvcs/blob/master/src/xsl/svn2prov.xsl>;
#3>    prov:wasDerivedFrom   <http://dbpedia.org/resource/Eclipse_%28software%29>;
#3>    prov:wasDerivedFrom   <http://dbpedia.org/resource/JUnit>;
#3> .
-->

<xsl:transform version="2.0" 
   xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema"
   exclude-result-prefixes="">
<xsl:output method="text"/>

<!-- See https://github.com/timrdf/csv2rdf4lod-automation/wiki/SDV-organization -->
<xsl:param name="cr-base-uri"   select="'http://my.com'"/>
<xsl:param name="cr-source-id"  select="'epa-gov'"/>
<xsl:param name="cr-dataset-id" select="'some-dataset'"/>
<xsl:param name="cr-version-id" select="'latest'"/>
<xsl:param name="cr-portion-id" select="''"/>

<xsl:variable name="id"       select="concat($cr-base-uri,'/id')"/>
<xsl:variable name="abstract" select="concat($cr-base-uri,'/source/',$cr-source-id,'/dataset/',$cr-dataset-id)"/>
<xsl:variable name="sdv"      select="concat($cr-base-uri,'/source/',$cr-source-id,'/dataset/',$cr-dataset-id,'/version/',$cr-version-id)"/>
<xsl:variable name="version"  select="replace(replace(base-uri(),'^.*/[^/]',''),'\.xml$','')"/>

<xsl:template match="/">
   <xsl:value-of select="concat(
            '@prefix rdfs:    &lt;http://www.w3.org/2000/01/rdf-schema#&gt; .',$NL,
            '@prefix dcterms: &lt;http://purl.org/dc/terms/&gt; .',$NL,
            '@prefix earl:    &lt;http://www.w3.org/ns/earl#&gt; .',$NL,
            '@prefix prov:    &lt;http://www.w3.org/ns/prov#&gt; .',$NL,
            '@prefix sio:     &lt;http://semanticscience.org/resource/&gt; .',$NL,
            '@prefix time:    &lt;http://www.w3.org/TR/owl-time#&gt; .',$NL,
            '@prefix vocab:   &lt;',$abstract,'/vocab/&gt; .',$NL,
            '@prefix :        &lt;',$sdv,'/&gt; .',$NL
         )"/>
   <xsl:apply-templates select="testrun"/>
</xsl:template>

<xsl:template match="testrun">

   <!-- <testrun name="all smart" project="data-sculptor" tests="146" started="146" failures="27" errors="1" ignored="0"> -->
   <xsl:value-of select="concat($NL,
      '&lt;','testrun','&gt;',$NL,
      '   a vocab:TestRun;',$NL,
      '   rdfs:seeAlso &lt;',$version,'&gt;;',$NL,
      if( string-length(@project) )
         then concat('   dcterms:isPartOf &lt;',$abstract,'/',@project,'&gt;;',$NL) 
         else '',
      if( string-length(@name) )
         then concat('   dcterms:title ',$DQ,@name,$DQ,';',$NL) 
         else '',
      if( string-length(@tests) )
         then concat('   sio:count ',@tests,';',$NL) 
         else '',
      if( string-length(@started) )
         then concat('   vocab:started ',@started,';',$NL) 
         else '',
      if( string-length(@failures) )
         then concat('   vocab:failures ',@failures,';',$NL) 
         else '',
      if( string-length(@errors) )
         then concat('   vocab:errors ',@errors,';',$NL) 
         else '',
      if( string-length(@ignored) )
         then concat('   vocab:ignored ',@ignored,';',$NL) 
         else ''
   )"/>
   
   <xsl:for-each select="testsuite">
      <xsl:value-of select="concat('   dcterms:hasPart &lt;',@name,'&gt;;',$NL)"/>
   </xsl:for-each>

   <xsl:value-of select="concat(
      '.',$NL
   )"/>

   <xsl:apply-templates select="testsuite"/>
</xsl:template>

<xsl:template match="testsuite">
   <!-- 
     <testsuite name="org.us.someproject.somemodule.TestSomeClass" time="14.5">
       <testcase name="test" classname="org.us.someproject.somemodule.shimmers.TestWebPageDataFAQsReportShimmer" time="14.5"/>
     </testsuite>

     <testsuite name="org.us.someproject.somemodule.TestSomeOtherClass" time="0.527">
       <testcase name="distinctGraphsIn" classname="org.us.someproject.somemodule.TestAnotherCase" time="0.527">
         <failure>java.lang.AssertionError: Function org.us.someproject.somemodule.liftlets.AnotherCase should have been applicable
      at org.junit.Assert.fail(Assert.java:88)
   -->
   <xsl:value-of select="concat($NL,
      '&lt;',@name,'/run/',$version,'&gt;',$NL,
      '   a prov:Activity;',$NL,
      '   prov:specializationOf &lt;',@name,'&gt;;',$NL,
      if( string-length(@project) )
         then concat('   dcterms:hasPart &lt;',@name,'/',@name,'&gt;;',$NL) 
         else '',
      if( string-length(@name) )
         then concat('   dcterms:title ',$DQ,@name,$DQ,';',$NL) 
         else '',
      if( string-length(@time) )
         then concat('   time:hasDurationDescription &lt;',$id,'/seconds/',@time,'&gt;;',$NL) 
         else ''
   )"/>

   <xsl:value-of select="concat(
      '.',$NL,
      if( string-length(@time) )
         then concat($NL,'&lt;',$id,'/seconds/',@time,'&gt;',$NL,
                     '   time:seconds ',@time,' ;',$NL,
                     '   rdfs:label ',$DQ,@time,' seconds',$DQ,';',$NL,
                     '.',$NL) 
         else ''
   )"/>
   <xsl:apply-templates select="testcase"/>
</xsl:template>

<xsl:template match="testcase">

   <xsl:value-of select="concat($NL,
      '&lt;',../@name,'/',@name,'&gt;',$NL,
      '   a earl:TestCase, prov:Entity;',$NL,
      '   rdfs:isDefinedBy &lt;java:',../@name,'#',@name,'&gt;;',$NL,
      if( string-length(@project) )
         then concat('   dcterms:hasPart &lt;',@name,'/',@name,'&gt;;',$NL) 
         else '',
      if( string-length(@name) )
         then concat('   dcterms:title ',$DQ,@name,$DQ,';',$NL) 
         else ''
   )"/>

   <xsl:for-each select="testcase">
      <xsl:value-of select="concat('   dcterms:hasPart &lt;',../../@name,'/',../@name,'/',@name,'&gt;;',$NL)"/>
   </xsl:for-each>

   <xsl:value-of select="concat(
      '.',$NL
   )"/>

   <xsl:value-of select="concat($NL,
      '&lt;java:',../@name,'#',@name,'&gt;',$NL,
      '   dcterms:isPartOf &lt;java:',../@name,'&gt;;',$NL,
      '.',$NL
   )"/>

   <xsl:value-of select="concat($NL,
      '&lt;',../@name,'/',@name,'/',$version,'&gt;',$NL,
      '   a earl:Assertion, prov:Entity;',$NL,
      '   prov:wasGeneratedBy &lt;',../@name,'/',@name,'/run/',$version,'&gt;;',$NL,
      '   earl:mode           earl:automatic;',$NL,
      '   earl:assertedBy     &lt;java:',../@name,'#',@name,'&gt;;',$NL,
      '   earl:test           &lt;',../@name,'/',@name,'&gt;;',$NL,
      '   earl:subject        &lt;java:',replace(../@name,'\.Test','.'),'&gt;;',$NL,
      '.',$NL
   )"/>

   <xsl:value-of select="concat($NL,
      '&lt;',../@name,'/',@name,'/run/',$version,'&gt;',$NL,
      '   a prov:Activity;',$NL,
      '   prov:wasInformedBy &lt;',../@name,'/run/',$version,'&gt;;',$NL,
      '   time:hasDurationDescription &lt;',$id,'/seconds/',@time,'&gt;;',$NL,
      '.',$NL
   )"/>

   <xsl:value-of select="concat($NL,
      '&lt;',$id,'/seconds/',@time,'&gt;',$NL,
      if( string-length(@time) )
         then concat('   time:seconds ',@time,';',$NL,
                     '   rdfs:label ',$DQ,@time,' seconds',$DQ,';')
         else '',
      $NL,'.'
   )"/>

   <xsl:value-of select="concat($NL,
      '&lt;',../@name,'/',@name,'/',$version,'/result&gt;',$NL,
      '   a earl:TestResult, prov:Entity;',$NL,
      '   earl:outcome &lt;',../@name,'/',@name,'/',$version,'/result&gt;;',$NL,
      if( failure )
         then concat('   a earl:Fail;',$NL,
                     '   earl:info ',$DQ,$DQ,$DQ,failure/text(),$DQ,$DQ,$DQ,';',$NL) 
         else concat('   a earl:Pass;',$NL),
      '.',$NL
   )"/>

</xsl:template>

<xsl:variable name="NL" select="'&#xa;'"/>
<xsl:variable name="DQ" select="'&#x22;'"/>

</xsl:transform>
