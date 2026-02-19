import logo from '/images/logo.png';
import './Logo.css'

function Logo() {
    return (
        <div className="logo">
            <img src={logo} alt="Logo" className="logo-img" />
        </div>
    );
}

export default Logo;