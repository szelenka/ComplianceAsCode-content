documentation_complete: true

metadata:
   version: V1R1
   SMEs:
     - szelenka

title: 'Standard System Security Profile for CrunchyData Postgres'

description: |-
    This profile is developed under the DoD consensus model and DISA FSO Vendor STIG process,
    serving as the upstream development environment for the CrunchyData Postgres STIG.

    As a result of the upstream/downstream relationship between the SCAP Security Guide project
    and the official DISA FSO STIG baseline, users should expect variance between SSG and DISA FSO content.

    While this profile is packaged by Red Hat as part of the SCAP Security Guide package, please note
    that commercial support of this SCAP content is NOT available. This profile is provided as example
    SCAP content with no endorsement for suitability or production readiness. Support for this
    profile is provided by the upstream SCAP Security Guide community on a best-effort basis. The
    upstream project homepage is https://www.open-scap.org/security-policies/scap-security-guide/.

selections:
    - installed_crunchy-data-postgres_version_supported
    - file_groupowner-pg_log
    - file_owner-pg_log
    - file_permissions-pg_log
    - file_permissions-pg_log_log
