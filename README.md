# Git: Get modified line numbers
This GitHub Action allows you to find the line numbers of all modified or added files in the last commit of a Git repository and output the results in JSON format.
The action can be added to any workflow to automate this process and make the results easily accessible.
This action does not return results from deleted files or deleted lines.

It doesn't take any inputs.
## Output

### `modified_lines`

A JSON object listing filenames and modified line numbers in that file.
## Usage

```yaml
- name: Get modified files and lines
  id: modified-lines
  uses: gaurav-nelson/git-get-modified-line-numbers@v1
```

You can access the output of this action in subsequent steps using the following syntax:

```yaml
${{ steps.list-modified-lines.outputs.modified_lines }}
```

The output is in the following JSON format:

```json
{"/backup_and_restore/backing-up-acs.adoc":[18,19,32,33],"/modules/on-demand-backups-roxctl-admin-pass.adoc":[430,29,3438,37],"/modules/on-demand-backups-roxctl-api.adoc":[17,16,37,36]}
```

## Contributing
If you find a bug or would like to suggest a feature, please open an issue on the GitHub repository.
If you would like to contribute code, please fork the repository and create a pull request with your changes.

## License
This action is licensed under the MIT License.
See the LICENSE file for more information.
