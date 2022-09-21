from argparse import ArgumentParser
from git import Repo
from os import mkdir, walk
from os.path import exists, join, splitext

def write_tag_file(repo, deps_dir, commit, tag_file):
    packages = {}
    for dir, dirs, files in walk(deps_dir):
        for d in dirs:
            package_id         = splitext(url)[0].split('/')
            package_id.pop(0)
            package_id.pop(0)
            deps_repo          = Repo(join(dir, d))
            url                = deps_repo.remotes.origin.url.split(':/')[-1]
            package            = '/'.join(package_id)
            packages[package]  = deps_repo.git.rev_list('-1', f'--before="{commit.authored_date}"', 'HEAD')
        break

    print(f"Creating tag_file '{commit}'")
    with open(tag_file, 'w') as f:
        f.write('---COMMITID BEGIN---\n')
        for package, commit_id in sorted(packages.items()):
            if commit_id:
                f.write(f"{package}: {commit_id}\n")
        f.write('---COMMITID END---')

repo = Repo('.')

def parse_args():
    parser = ArgumentParser(usage='Generates tag files for given commit range.')
    parser.add_argument('--path',  required=True, help='Path to the build folder')
    parser.add_argument('--start', required=True, help='First commit')
    parser.add_argument('--end',   required=True, help='Last commit')
    parser.add_argument('--out',   required=True, help='Output folder')
    return parser.parse_args()

args = parse_args();

if not oexists(args.out):
    mkdir(args.out)

for commit in repo.iter_commits(rev=f'{args.start}..{args.end}'):
    write_tag_file(repo, f'{args.path}/deps', commit, f'{args.out}/{commit.hexsha}')
