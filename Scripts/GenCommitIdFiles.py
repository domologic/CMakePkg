import argparse
import os
import os.path
import git
import time

def writeTagfile(repo, depsdir, commit, tagfile):
    packages = {}
    for subdir, dirs, files in os.walk(depsdir):
        for d in dirs:
            depsrepo           = git.Repo(os.path.join(subdir, d))
            url                = depsrepo.remotes.origin.url.split(':/')[-1]
            package_id         = os.path.splitext(url)[0].split('/');
            package_id.pop(0)
            package_id.pop(0)
            package            = '/'.join(package_id)
            packages[package]  = depsrepo.git.rev_list('-1', f'--before="{commit.authored_date}"', 'HEAD')
        break

    print(f"Creating tagfile '{commit}'")
    with open(tagfile, 'w') as f:
        print('---COMMITID BEGIN---\n')
        for package, commitid in sorted(packages.items()):
            if commitid:
                f.write(f"{package}: {commitid}\n")
        print('---COMMITID END---')

repo = git.Repo(".")

def parse_args():
    parser = argparse.ArgumentParser(usage='Generates tag files for given commit range.')
    parser.add_argument('--path',  required=True, help='Path to the build folder')
    parser.add_argument('--start', required=True, help='First commit')
    parser.add_argument('--end',   required=True, help='Last commit')
    parser.add_argument('--out',   required=True, help='Output folder')
    return parser.parse_args()

args = parse_args();

if not os.path.exists(args.out):
    os.mkdir(args.out)

for commit in repo.iter_commits(rev=f'{args.start}..{args.end}'):
    writeTagfile(repo, f'{args.path}/deps', commit, f'{args.out}/{commit.hexsha}')
