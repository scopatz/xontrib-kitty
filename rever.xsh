$GITHUB_ORG = 'scopatz'
$PROJECT = $GITHUB_REPO = 'xontrib-kitty'
$WEBSITE_URL = 'https://github.com/scopatz/xontrib-kitty'
$ACTIVITIES = [#'authors',
               'version_bump', 'changelog',
               'tag', 'push_tag', 'ghrelease',
               'pypi', #'conda_forge',
               ]


$AUTHORS_FILENAME = "AUTHORS.rst"
$VERSION_BUMP_PATTERNS = [
    ('xontrib_kitty/__init__.py', r'__version__\s*=.*', '__version__ = "$VERSION"'),
    ('setup.py', r'version\s*=.*', 'version="$VERSION",'),
    ]
$CHANGELOG_FILENAME = 'CHANGELOG.rst'
$CHANGELOG_TEMPLATE = 'TEMPLATE.rst'

$TAG_REMOTE = 'git@github.com:scopatz/xontrib-kitty.git'
$TAG_TARGET = 'master'

