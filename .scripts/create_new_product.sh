#!/bin/bash
# ref : https://complianceascode.readthedocs.io/en/latest/manual/developer/03_creating_content.html

set -e 

export SHORTNAME="Postgres"
export VENDOR="crunchy-data"
export PRODUCT="postgres"
export NAME="${VENDOR}-${PRODUCT}"
export CAMEL_CASE_NAME="CrunchyData Postgres"
export VERSION="14"
export FULL_NAME="${CAMEL_CASE_NAME}"
export FULL_SHORT_NAME="${SHORTNAME}"
export NEW_PRODUCT="${NAME}"
export CAPITAL_NAME="CRUNCHYDATAPOSTGRES"
export GIT_USERNAME=$(git config user.name)

echo ">>> Create product folder structure"
# ref : https://complianceascode.readthedocs.io/en/latest/manual/developer/06_contributing_with_content.html#rule-directories
mkdir -p \
    products/${NEW_PRODUCT} \
    products/${NEW_PRODUCT}/checks/oval \
    products/${NEW_PRODUCT}/guide/${NEW_PRODUCT} \
    products/${NEW_PRODUCT}/guide/${NEW_PRODUCT}/installed_${NEW_PRODUCT}_version_supported/oval \
    products/${NEW_PRODUCT}/profiles \
    products/${NEW_PRODUCT}/transforms


echo ">>> ensure we're starting from latest on main branch"
git checkout master -- CMakeLists.txt ssg/constants.py build_product


echo ">>> Add to CMakeLists.txt"
sed -i -e '/^option(SSG_PRODUCT_UBUNTU2004/a\'$'\noption(SSG_PRODUCT_'"${CAPITAL_NAME}"' "If enabled, the '"${FULL_NAME}"' SCAP content will be built" ${SSG_PRODUCT_DEFAULT})'$'\n' CMakeLists.txt
sed -i -e '/^message(STATUS "Ubuntu 20.04:/a\'$'\nmessage(STATUS "'"${FULL_NAME}"': ${SSG_PRODUCT_'"${CAPITAL_NAME}"'}")'$'\n' CMakeLists.txt
sed -i -e '/^if (SSG_PRODUCT_UBUNTU2004)/i\'$'\nif (SSG_PRODUCT_'"${CAPITAL_NAME}"')'$'\n' CMakeLists.txt
sed -i -e '/^if (SSG_PRODUCT_'"${CAPITAL_NAME}"')/a\'$'\n     add_subdirectory("products/'"${NEW_PRODUCT}"'" "'"${NEW_PRODUCT}"'")'$'\n' CMakeLists.txt
sed -i -e '/^if (SSG_PRODUCT_UBUNTU2004)/i\'$'\nendif()'$'\n' CMakeLists.txt
rm -f CMakeLists.txt-e

echo ">>> Add to build_product script"
sed -i -e '/^all_cmake_products=(/a\'$'\n	'"${CAPITAL_NAME}"$'\n' build_product
rm -f build_product-e

echo ">>> Add to constants.py"
sed -i -e '/^product_directories = \[/a\'$'\n    "'"${NEW_PRODUCT}"'",'$'\n' ssg/constants.py
sed -i -e '/^FULL_NAME_TO_PRODUCT_MAPPING = {/a\'$'\n    "'"${FULL_NAME}"'": "'"${NEW_PRODUCT}"'",'$'\n' ssg/constants.py
# These seem to only apply to OS level "platforms" not applications
# sed -i -e '/^MULTI_PLATFORM_LIST = \[/a\'$'\n                       "'"${NEW_PRODUCT}"'",'$'\n' ssg/constants.py
# sed -i -e '/^MULTI_PLATFORM_MAPPING = {/a\'$'\n    "multi_platform_'"${NEW_PRODUCT}"'": ["'"${NEW_PRODUCT}"'"],'$'\n' ssg/constants.py
sed -i -e '/^MAKEFILE_ID_TO_PRODUCT_MAP = {/a\'$'\n    "'"${NAME}"'": "'"${CAMEL_CASE_NAME}"'",'$'\n' ssg/constants.py
rm -f ssg/constants.py-e

echo ">>> Create a new file in the product directory called CMakeList.txt"
cat << EOF > products/${NEW_PRODUCT}/CMakeLists.txt
# Sometimes our users will try to do: "cd ${NEW_PRODUCT}; cmake ." That needs to error in a nice way.
if ("\${CMAKE_SOURCE_DIR}" STREQUAL "\${CMAKE_CURRENT_SOURCE_DIR}")
    message(FATAL_ERROR "cmake has to be used on the root CMakeLists.txt, see the Building ComplianceAsCode section in the Developer Guide!")
endif()

ssg_build_product("${NEW_PRODUCT}")
EOF


echo ">>> Create a new file in the product directory called product.yml (note: you may want to change the pkg_manager attribute):"
cat << EOF > products/${NEW_PRODUCT}/product.yml
product: ${NEW_PRODUCT}
full_name: ${FULL_NAME}
type: platform

benchmark_id: ${CAPITAL_NAME}
benchmark_root: "./guide"

profiles_root: "./profiles"

pkg_manager: "apt_get"

cpes_root: "../../shared/applicability"
cpes:
  - ${NEW_PRODUCT}:
      name: "cpe:/o:${VENDOR}:${PRODUCT}"
      title: "${FULL_NAME}"
      check_id: installed_app_is_${NEW_PRODUCT}

reference_uris:
  cis: 'https://www.cisecurity.org/benchmark/ubuntu_linux/'
EOF


echo ">>> Create benchmark.yml"
cat << EOF > products/${NEW_PRODUCT}/guide/benchmark.yml
---
documentation_complete: true

title: Guide to the Secure Configuration of {{{ full_name }}}

status: draft

description: |
    This guide presents a catalog of security-relevant
    configuration settings for {{{ full_name }}}. It is a rendering of
    content structured in the eXtensible Configuration Checklist Description Format (XCCDF)
    in order to support security automation.  The SCAP content is
    is available in the <tt>scap-security-guide</tt> package which is developed at
    {{{ weblink(link="https://www.open-scap.org/security-policies/scap-security-guide") }}}.
    <br/><br/>
    Providing system administrators with such guidance informs them how to securely
    configure systems under their control in a variety of network roles. Policy
    makers and baseline creators can use this catalog of settings, with its
    associated references to higher-level security control catalogs, in order to
    assist them in security baseline creation. This guide is a <em>catalog, not a
    checklist</em>, and satisfaction of every item is not likely to be possible or
    sensible in many operational scenarios. However, the XCCDF format enables
    granular selection and adjustment of settings, and their association with OVAL
    and OCIL content provides an automated checking capability. Transformations of
    this document, and its associated automated checking content, are capable of
    providing baselines that meet a diverse set of policy objectives. Some example
    XCCDF <em>Profiles</em>, which are selections of items that form checklists and
    can be used as baselines, are available with this guide. They can be
    processed, in an automated fashion, with tools that support the Security
    Content Automation Protocol (SCAP). The DISA STIG for {{{ full_name }}},
    which provides required settings for US Department of Defense systems, is
    one example of a baseline created from this guidance.

notice:
    id: terms_of_use
    description: |
        Do not attempt to implement any of the settings in
        this guide without first testing them in a non-operational environment. The
        creators of this guidance assume no responsibility whatsoever for its use by
        other parties, and makes no guarantees, expressed or implied, about its
        quality, reliability, or any other characteristic.

front-matter: |
    The SCAP Security Guide Project<br/>
    {{{ weblink(link="https://www.open-scap.org/security-policies/scap-security-guide") }}}

rear-matter: |
    Red Hat and Red Hat Enterprise Linux are either registered
    trademarks or trademarks of Red Hat, Inc. in the United States and other
    countries. All other names are registered trademarks or trademarks of their
    respective companies.

version: 0.1
EOF


echo ">>> "
cat << EOF > products/${NEW_PRODUCT}/guide/${NEW_PRODUCT}/group.yml
documentation_complete: true

title: ${FULL_NAME}

description: |-
    This section provides settings for configuring ${FULL_NAME} policies to meet compliance
    settings for ${FULL_NAME} running on Red Hat Enterprise Linux systems.

    <ul>Refer to <li>{{{ weblink(link="http://kb.mozillazine.org/${CAMEL_CASE_NAME}_:_FAQs_:_About:config_Entries") }}}</li>
    for a list of currently supported ${FULL_NAME} settings.</ul>
EOF


echo ">>> Create a draft profile under profiles directory called standard.profile:"
# ref : https://complianceascode.readthedocs.io/en/latest/manual/developer/03_creating_content.html#profiles
cat << EOF > products/${NEW_PRODUCT}/profiles/standard.profile
documentation_complete: true

metadata:
   version: V1R1
   SMEs:
     - ${GIT_USERNAME}

title: 'Standard System Security Profile for ${FULL_NAME}'

description: |-
    This profile is developed under the DoD consensus model and DISA FSO Vendor STIG process,
    serving as the upstream development environment for the ${FULL_NAME} STIG.

    As a result of the upstream/downstream relationship between the SCAP Security Guide project
    and the official DISA FSO STIG baseline, users should expect variance between SSG and DISA FSO content.

    While this profile is packaged by Red Hat as part of the SCAP Security Guide package, please note
    that commercial support of this SCAP content is NOT available. This profile is provided as example
    SCAP content with no endorsement for suitability or production readiness. Support for this
    profile is provided by the upstream SCAP Security Guide community on a best-effort basis. The
    upstream project homepage is https://www.open-scap.org/security-policies/scap-security-guide/.

selections:
    - installed_${NEW_PRODUCT}_version_supported
EOF


echo ">>> Create products/${NEW_PRODUCT}/guide/${NEW_PRODUCT}/installed_${NEW_PRODUCT}_version_supported/rule.yml"
# ref : https://complianceascode.readthedocs.io/en/latest/manual/developer/06_contributing_with_content.html#rules
cat << EOF > products/${NEW_PRODUCT}/guide/${NEW_PRODUCT}/installed_${NEW_PRODUCT}_version_supported/rule.yml
documentation_complete: true

prodtype: ${NEW_PRODUCT}

title: 'Supported Version of ${CAMEL_CASE_NAME} Installed'

description: |-
    If the system is joined to the Red Hat Network, a Red Hat Satellite Server,
    or a yum server, run the following command to install updates:
    <pre>$ sudo yum update</pre>
    If the system is not configured to use one of these sources, updates (in the form of RPM packages)
    can be manually downloaded and installed using <tt>rpm</tt>.

rationale: |-
    Use of versions of an application which are not supported by the vendor
    are not permitted. Vendors respond to security flaws with updates and
    patches. These updates are not available for unsupported version which
    can leave the application vulnerable to attack.

severity: high

references:
    disa: CCI-003376
    nist: SA-22
    stigid@${NEW_PRODUCT}: FFOX-00-000001

ocil_clause: 'it is not updated'

ocil: |-
    If the system is joined to the Red Hat Network, a Red Hat Satellite Server, or
    a yum server which provides updates, invoking the following command will
    indicate if updates are available:
    <pre>$ sudo yum check-update</pre>
    If the system is not configured to update from one of these sources,
    run the following command to list when each package was last updated:
    <pre>$ rpm -qa -last</pre>
    Compare this to Red Hat Security Advisories (RHSA) listed at
    {{{ weblink(link="https://access.redhat.com/security/updates/active/") }}}
    to determine if the system is missing applicable updates.
EOF


echo ">>> Create products/${NEW_PRODUCT}/guide/${NEW_PRODUCT}/installed_${NEW_PRODUCT}_version_supported/oval/${NEW_PRODUCT}.xml"
# ref : https://complianceascode.readthedocs.io/en/latest/manual/developer/06_contributing_with_content.html#checks
cat << EOF > products/${NEW_PRODUCT}/guide/${NEW_PRODUCT}/installed_${NEW_PRODUCT}_version_supported/oval/${NEW_PRODUCT}.xml
<def-group>
  <definition class="compliance" id="installed_${NEW_PRODUCT}_version_supported"  version="1">
    <metadata>
      <title>Supported Version of ${CAMEL_CASE_NAME} Installed</title>
      <affected family="unix">
        <platform>${CAMEL_CASE_NAME}</platform>
      </affected>
      <description>Use of versions of an application which are not
      supported by the vendor are not permitted. Vendors respond to
      security flaws with updates and patches. These updates are not
      available for unsupported versions which can leave the application
      vulnerable to attack.</description>
    </metadata>
    <criteria>
      <criterion comment="installed version of ${NEW_PRODUCT} supported" test_ref="test_supported_version_of_${NEW_PRODUCT}" />
    </criteria>
  </definition>

  <linux:rpminfo_test check="all" check_existence="any_exist" comment="Installed version of ${NEW_PRODUCT} is greater than ${VERSION}.0" id="test_supported_version_of_${NEW_PRODUCT}" version="1">
    <linux:object object_ref="obj_supported_version_of_${NEW_PRODUCT}" />
    <linux:state state_ref="state_supported_version_of_${NEW_PRODUCT}" />
  </linux:rpminfo_test>
  <linux:rpminfo_state id="state_supported_version_of_${NEW_PRODUCT}" version="1">
    <linux:evr operation="greater than" datatype="evr_string">${VERSION}.0</linux:evr> 
  </linux:rpminfo_state>
<linux:rpminfo_object id="obj_supported_version_of_${NEW_PRODUCT}" version="1">
    <linux:name>${NEW_PRODUCT}</linux:name>
 </linux:rpminfo_object>

{{% if pkg_system == "rpm" %}}
  <linux:rpminfo_test check="all" check_existence="any_exist" comment="Installed version of ${NEW_PRODUCT} is greater than ${VERSION}.0" id="test_supported_version_of_${NEW_PRODUCT}" version="1">
    <linux:object object_ref="obj_supported_version_of_${NEW_PRODUCT}" />
    <linux:state state_ref="state_supported_version_of_${NEW_PRODUCT}" />
  </linux:rpminfo_test>
  <linux:rpminfo_state id="state_supported_version_of_${NEW_PRODUCT}" version="1">
    <linux:evr operation="greater than" datatype="evr_string">${VERSION}.0</linux:evr> 
  </linux:rpminfo_state>
<linux:rpminfo_object id="obj_supported_version_of_${NEW_PRODUCT}" version="1">
    <linux:name>${NEW_PRODUCT}</linux:name>
  </linux:rpminfo_object>
{{% elif pkg_system == "dpkg" %}}
  <linux:dpkginfo_test check="all" check_existence="any_exist" comment="Installed version of ${NEW_PRODUCT} is greater than ${VERSION}.0" id="test_supported_version_of_${NEW_PRODUCT}" version="1">
    <linux:object object_ref="obj_supported_version_of_${NEW_PRODUCT}" />
    <linux:state state_ref="state_supported_version_of_${NEW_PRODUCT}" />
  </linux:dpkginfo_test>
  <linux:dpkginfo_state id="state_supported_version_of_${NEW_PRODUCT}" version="1">
    <linux:evr operation="greater than" datatype="evr_string">${VERSION}.0</linux:evr> 
  </linux:dpkginfo_state>
<linux:dpkginfo_object id="obj_supported_version_of_${NEW_PRODUCT}" version="1">
    <linux:name>${NEW_PRODUCT}</linux:name>
  </linux:dpkginfo_object>
{{% endif %}}

</def-group>
EOF


echo ">>> Create a new file under transforms directory called constants.xslt (you may want to review the links below):"
cat << EOF > products/${NEW_PRODUCT}/transforms/constants.xslt
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:include href="../../../shared/transforms/shared_constants.xslt"/>

<xsl:variable name="product_long_name">${FULL_NAME}</xsl:variable>
<xsl:variable name="product_short_name">$FULL_SHORT_NAME</xsl:variable>
<xsl:variable name="product_stig_id_name">${CAPITAL_NAME}_STIG</xsl:variable>
<xsl:variable name="prod_type">${NEW_PRODUCT}</xsl:variable>

<xsl:variable name="cisuri">empty</xsl:variable>

</xsl:stylesheet>

<!-- Define URI for custom policy reference which can be used for linking to corporate policy for ${FULL_NAME} -->
<!--xsl:variable name="custom-ref-uri">https://www.example.org</xsl:variable-->

</xsl:stylesheet>
EOF


echo ">>> Create a new file under transforms directory called table-style.xslt:"
cat << EOF > products/${NEW_PRODUCT}/transforms/table-style.xslt
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:import href="../../../shared/transforms/shared_table-style.xslt"/>

</xsl:stylesheet>
EOF


echo ">>> Create a new file under transforms directory called xccdf-apply-overlay-stig.xslt:"
cat << EOF > products/${NEW_PRODUCT}/transforms/xccdf-apply-overlay-stig.xslt
<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://checklists.nist.gov/xccdf/1.1" xmlns:xccdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xccdf">

<xsl:include href="../../../shared/transforms/shared_xccdf-apply-overlay-stig.xslt"/>
<xsl:include href="constants.xslt"/>
<xsl:variable name="overlays" select="document(\$overlay)/xccdf:overlays" />

</xsl:stylesheet>
EOF


echo ">>> Create a new file under transforms directory called xccdf2table-cce.xslt:"
cat << EOF > products/${NEW_PRODUCT}/transforms/xccdf2table-cce.xslt
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cce="http://cce.mitre.org" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:xhtml="http://www.w3.org/1999/xhtml">

<xsl:import href="../../../shared/transforms/shared_xccdf2table-cce.xslt"/>

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

</xsl:stylesheet>
EOF


echo ">>> Create a new file under transforms directory called xccdf2table-profileccirefs.xslt:"
cat << EOF > products/${NEW_PRODUCT}/transforms/xccdf2table-profileccirefs.xslt
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:cdf="http://checklists.nist.gov/xccdf/1.1" xmlns:cci="https://public.cyber.mil/stigs/cci" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:ovalns="http://oval.mitre.org/XMLSchema/oval-definitions-5">

<xsl:import href="../../../shared/transforms/shared_xccdf2table-profileccirefs.xslt"/>

<xsl:include href="constants.xslt"/>
<xsl:include href="table-style.xslt"/>

</xsl:stylesheet>
EOF


echo ">>> Create a new file under products/${NEW_PRODUCT}/checks/oval directory called installed_app_is_${NEW_PRODUCT}.xml:"
# cat << EOF > products/${NEW_PRODUCT}/checks/oval/installed_app_is_${NEW_PRODUCT}.xml
# <def-group>
#   <definition class="inventory" id="installed_app_is_${NEW_PRODUCT}" version="1">
#     <metadata>
#       <title>${FULL_NAME}</title>
#       <affected family="unix">
#         <platform>${FULL_NAME}</platform>
#       </affected>
#       <reference ref_id="cpe:/o:${VENDOR}:${PRODUCT}" source="CPE" />
#       <description>The application installed on the system is ${FULL_NAME}</description>
#     </metadata>
#     <criteria comment="current version is ${VERSION}" operator="AND">
#       <extend_definition comment="Installed OS is part of the Unix family"
#       definition_ref="installed_OS_is_part_of_Unix_family" />
#       <criterion comment="${CAMEL_CASE_NAME} is installed" test_ref="test_${NEW_PRODUCT}" />
#     </criteria>
#   </definition>

# {{% if pkg_system == "rpm" %}}
#   <linux:rpminfo_test check="all" check_existence="at_least_one_exists" comment="${FULL_NAME} is installed via RPM" id="test_${NEW_PRODUCT}" version="1">
#     <linux:object object_ref="obj_${NEW_PRODUCT}" />
#   </linux:rpminfo_test>
#   <linux:rpminfo_object id="obj_${NEW_PRODUCT}" version="1">
#     <linux:name>${NEW_PRODUCT}</linux:name>
#   </linux:rpminfo_object>
# {{% elif pkg_system == "dpkg" %}}
#   <linux:dpkginfo_test check="all" check_existence="at_least_one_exists" comment="${FULL_NAME} is installed via DPKG" id="test_${NEW_PRODUCT}" version="1">
#     <linux:object object_ref="obj_${NEW_PRODUCT}" />
#   </linux:dpkginfo_test>
#   <linux:dpkginfo_object id="obj_${NEW_PRODUCT}" version="1">
#     <linux:name>${NEW_PRODUCT}</linux:name>
#   </linux:dpkginfo_object>
# {{% endif %}}

# </def-group>
# EOF

cat << EOF > products/${NEW_PRODUCT}/checks/oval/installed_app_is_${NEW_PRODUCT}.xml
<def-group>
  <definition class="inventory" id="installed_app_is_${NEW_PRODUCT}" version="1">
    <metadata>
      <title>${CAMEL_CASE_NAME}</title>
      <affected family="unix">
        <platform>${CAMEL_CASE_NAME}</platform>
      </affected>
      <reference ref_id="cpe:/o:${VENDOR}:${PRODUCT}" source="CPE" />
      <description>The application installed on the system is ${CAMEL_CASE_NAME}</description>
    </metadata>
    <criteria>
      <criterion comment="${CAMEL_CASE_NAME} is installed" test_ref="test_installed_app_is_${NEW_PRODUCT}" />
    </criteria>
  </definition>

  <ind:environmentvariable58_object id="obj_installed_app_is_${NEW_PRODUCT}_pgver" version="1">
    <ind:pid xsi:nil="true" datatype="int" />
    <ind:name>PGVER</ind:name>
  </ind:environmentvariable58_object>

  <local_variable comment="Expose path for PGDATA" datatype="string" id="var_installed_app_is_${NEW_PRODUCT}_pgver" version="1">
    <concat>
      <literal_component>/usr/pgsql-</literal_component>
      <object_component item_field="value" object_ref="obj_installed_app_is_${NEW_PRODUCT}_pgver" />
      <literal_component>/bin/postgres</literal_component>
    </concat>
  </local_variable>

  <unix:file_test check="all" check_existence="all_exist" comment="Test that that /usr/pgsql-\${PGVER?}/bin/postgres does exist" id="test_installed_app_is_${NEW_PRODUCT}" version="1">
    <unix:object object_ref="obj_installed_app_is_${NEW_PRODUCT}" />
    <unix:state state_ref="state_installed_app_is_${NEW_PRODUCT}" />
  </unix:file_test>

  <unix:file_object id="obj_installed_app_is_${NEW_PRODUCT}" version="1">
    <unix:filepath var_ref="var_installed_app_is_${NEW_PRODUCT}_pgver"/>
  </unix:file_object>

  <unix:file_state id="state_installed_app_is_${NEW_PRODUCT}" version="1">
    <unix:uexec datatype="boolean">true</unix:uexec>
    <unix:gexec datatype="boolean">true</unix:gexec>
    <unix:oexec datatype="boolean">true</unix:oexec>
  </unix:file_state>

</def-group>
EOF

# echo ">>> Add ${FULL_NAME} to shared/checks/oval/installed_OS_is_part_of_Unix_family.xml"
# sed -i -e '</affected>/i\'$'\n        <product>'"${FULL_NAME}"'</product>' shared/checks/oval/installed_OS_is_part_of_Unix_family.xml
# rm -f shared/checks/oval/installed_OS_is_part_of_Unix_family.xml-e
