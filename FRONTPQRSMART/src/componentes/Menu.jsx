import React, { useEffect } from 'react';
import '../componentes/Menu.css'
import { useNavigate } from 'react-router-dom';
import { FaPenClip } from "react-icons/fa6";
import { FaMagnifyingGlass } from "react-icons/fa6";
import { ImExit } from "react-icons/im";
import { RxDashboard } from "react-icons/rx";
import { RiContactsBook2Line } from "react-icons/ri";
import { IoHomeOutline } from "react-icons/io5";


export const Menu = () => {
  const handleLogout = () => {
    localStorage.setItem('loggetPQRSMART', 'false');
    localStorage.setItem('tokenPQRSMART', '');
    localStorage.setItem('userPQRSMART', JSON.stringify(''));
  };
  useEffect(() => {
    const listElements = document.querySelectorAll('.list__button--click');

    listElements.forEach((listElement) => {
      listElement.addEventListener('click', () => {
        listElement.classList.toggle('arrow');

        let height = 0;
        const menu = listElement.nextElementSibling;
        if (menu.clientHeight === 0) {
          height = menu.scrollHeight;
        }

        menu.style.height = `${height}px`;
      });
    });

    // Cleanup function to remove event listeners when the component unmounts
    return () => {
      listElements.forEach((listElement) => {
        listElement.removeEventListener('click', () => { });
      });
    };
  }, []);
  return (
    <div>
      <nav class="nav">
        <ul class="list">

          <li class="list__item">
            <div class="list__button">
              <img src="assets/dashboard.svg" class="list__img" />
              <a href="/HomePage" class="nav__link">Inicio</a>
            </div>
          </li>

          <li class="list__item">
            <div class="list__button">
              <FaPenClip />
              <a href="/Crear" class="nav__link">Crear PQRS</a>
            </div>
          </li>


          <li class="list__item">
            <div class="list__button">
              <FaMagnifyingGlass />
              <a href="/Consultar" class="nav__link">Consultar PQRS</a>
            </div>
          </li>

          <li class="list__item">
            <div class="list__button">
              <ImExit className='icon' />
              <a href="/Login" class="nav__link" onClick={handleLogout}>Salir</a>
            </div>
          </li>

        </ul>
      </nav>
    </div>
  );
}


export const MenuAdmin = () => {
  const navigate = useNavigate();
  const handleLogout = () => {
    localStorage.setItem('loggetPQRSMART', 'false');
    localStorage.setItem('tokenPQRSMART', '');
    localStorage.setItem('userPQRSMART', JSON.stringify(''));
    navigate('/Login');
  };
  useEffect(() => {
    const listElements = document.querySelectorAll('.list__button--click');

    listElements.forEach((listElement) => {
      listElement.addEventListener('click', () => {
        listElement.classList.toggle('arrow');

        let height = 0;
        const menu = listElement.nextElementSibling;
        if (menu.clientHeight === 0) {
          height = menu.scrollHeight;
        }

        menu.style.height = `${height}px`;
      });
    });

    // Cleanup function to remove event listeners when the component unmounts
    return () => {
      listElements.forEach((listElement) => {
        listElement.removeEventListener('click', () => { });
      });
    };
  }, []);
  return (
    <div>
      <nav class="nav">
        <ul class="list">

          <li class="list__item">
            <div class="list__button">
              <img src="assets/dashboard.svg" class="list__img" />
              <a href="/HomePagesAdmin" class="nav__link">Inicio</a>
            </div>
          </li>
          <li class="list__item">
            <div class="list__button">
              <img src="assets/stats.svg" class="list__img" />
              <a href="/Dashboard" class="nav__link">Estadisticas</a>
            </div>
          </li>

          <li class="list__item list__item--click">
            <div class="list__button list__button--click">
              <RiContactsBook2Line />
              <a href="#" class="nav__link">Gestion Usuario</a>
              <img src="assets/arrow.svg" class="list__arrow" />
            </div>

            <ul class="list__show">
              <li class="list__inside">
                <a href="/VerUsuario" class="nav__link nav__link--inside">Ver Usuario</a>
              </li>

              <li class="list__inside">
                <a href="/CrearUsuario" class="nav__link nav__link--inside">Crear Usuario</a>
              </li>
            </ul>

          </li>

          <li class="list__item list__item--click">
            <div class="list__button list__button--click">
              <RxDashboard />
              <a href="#" class="nav__link">Gestion Categorias</a>
              <img src="assets/arrow.svg" class="list__arrow" />
            </div>

            <ul class="list__show">
              <li class="list__inside">
                <a href="/VerCategoria" class="nav__link nav__link--inside">Ver Categorias</a>
              </li>

              <li class="list__inside">
                <a href="/CrearCategoria" class="nav__link nav__link--inside">Crear Categorias</a>
              </li>
            </ul>

          </li>

          <li class="list__item list__item--click">
            <div class="list__button list__button--click">
              <IoHomeOutline />
              <a href="#" class="nav__link">Gestion Dependencias</a>
              <img src="assets/arrow.svg" class="list__arrow" />
            </div>

            <ul class="list__show">
              <li class="list__inside">
                <a href="/VerDependencia" class="nav__link nav__link--inside">Ver Dependencias</a>
              </li>

              <li class="list__inside">
                <a href="/CrearDependencias" class="nav__link nav__link--inside">Crear Dependencias</a>
              </li>
            </ul>

          </li>
          <li class="list__item">
            <div class="list__button">
              <ImExit className='icon' />
              <a href="/Login" class="nav__link" onClick={handleLogout}>Salir</a>
            </div>
          </li>



        </ul>
      </nav>
    </div>
  );
}


export const MenuSecre = () => {
  const navigate = useNavigate();
  const handleLogout = () => {
    localStorage.setItem('loggetPQRSMART', 'false');
    localStorage.setItem('tokenPQRSMART', '');
    localStorage.setItem('userPQRSMART', JSON.stringify(''));
    navigate('/Login');
  };
  useEffect(() => {
    const listElements = document.querySelectorAll('.list__button--click');

    listElements.forEach((listElement) => {
      listElement.addEventListener('click', () => {
        listElement.classList.toggle('arrow');

        let height = 0;
        const menu = listElement.nextElementSibling;
        if (menu.clientHeight === 0) {
          height = menu.scrollHeight;
        }

        menu.style.height = `${height}px`;
      });
    });

    // Cleanup function to remove event listeners when the component unmounts
    return () => {
      listElements.forEach((listElement) => {
        listElement.removeEventListener('click', () => { });
      });
    };
  }, []);
  return (
    <div>
      <nav class="nav">
        <ul class="list">

          <li class="list__item">
            <div class="list__button">
              <img src="assets/dashboard.svg" class="list__img" />
              <a href="/HomePage" class="nav__link">Inicio</a>
            </div>
          </li>

          <li class="list__item">
            <div class="list__button">
              <FaPenClip />
              <a href="/GestionarPQRS" class="nav__link">Gestionar PQRS</a>
            </div>
          </li>

          <li class="list__item">
            <div class="list__button">
              <ImExit className='icon' />
              <a href="/Login" class="nav__link" onClick={handleLogout}>Salir</a>
            </div>
          </li>

        </ul>
      </nav>
    </div>
  );
}




