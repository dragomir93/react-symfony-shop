import { makeStyles } from '@mui/styles';

const useStyles = makeStyles((theme) => ({
    root: {
        flexGrow: 1,
    },
    appBar: {
        backgroundColor: theme.palette.customColors.backgroundLight,
        ' & > div': {
            display: 'flex',
            justifyContent: 'flex-end',
        },
    },
    logo: {
        marginTop: theme.spacing(2),
        marginBottom: theme.spacing(2),
        marginRight: 'auto',
        '& img': {
            height: '30px',
        },
    },
    accountCircle: {
        color: theme.palette.primary.main,
    },
    navigationWrapper: {
        height: 50,
        display: 'flex',
    },

    navigationItem: {
        fontSize: '1rem',
        color: theme.palette.primary.contrastText,
        padding: '0 10px',
        position: 'relative',
        textDecoration: 'none',
        display: 'flex',
        alignItems: 'center',

        '&.active::after, &:hover::after': {
            outline: 'none',
            position: 'absolute',
            content: '""',
            bottom: 0,
            left: 0,
            right: 0,
            height: 2,
            backgroundColor: theme.palette.primary.contrastText,
        },
        ' &:focus': {
            outline: 'none',
        },
    },
    profileNavigationItem: {
        fontSize: '1rem',
        color: theme.palette.primary.contrastText,
        display: 'flex',
        alignItems: 'center',
    },
}));

export default useStyles;
