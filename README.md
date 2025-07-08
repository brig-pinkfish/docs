# Pinkfish Documentation

This is the documentation site for Pinkfish - AI Agents for Work, built with Mintlify.

## Development

Install the [Mintlify CLI](https://www.npmjs.com/package/mintlify) to preview the documentation changes locally. To install, use the following command:

```bash
npm i -g mintlify
```

Install dependencies:

```bash
npm install
```

Run the following command at the root of your documentation (where docs.json is located):

```bash
mintlify dev
```

The development server will start and you can preview your changes at `http://localhost:3000`.

## Configuration

This site uses `docs.json` as its configuration file (not `mint.json`). The configuration includes:
- Site theme and colors
- Navigation structure
- Page organization

## Publishing Changes

Install our Github App to auto propagate changes from your repo to your deployment. Changes will be deployed to production automatically after pushing to the default branch. Find the link to install on your dashboard.

## Troubleshooting

- Mintlify dev isn't running - Run `mintlify install` to re-install dependencies.
- Page loads as a 404 - Make sure you are running in a folder with `docs.json`
- Dependencies issues - The project uses `sharp` for image processing which should install automatically
