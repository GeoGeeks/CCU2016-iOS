//
//  ViewController.swift
//  CCU2016
//
//  Created by Juan Ríos on 29/06/16.
//  Copyright © 2016 Esri Colombia. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var sideMenuContainer: UIView!
    @IBOutlet weak var sideMenuWidth: NSLayoutConstraint!
    @IBOutlet weak var introImage: UIImageView!
    
    var sideMenuIsOpen:Bool!
    var isUser: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpHeader()
        self.setUpSideMenu()
        self.setupImages()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        self.sideMenuWidth.constant = 0
        self.sideMenuIsOpen = false
        
        self.isUserFunc()
        if !self.isUser{
            self.noRegisteredUser()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sideBarButton_Click(sender: UIBarButtonItem) {
        self.toggleSideMenu()
    }
    
    //SideMenu-----
    func setUpSideMenu(){
        let menuSwipe = UISwipeGestureRecognizer(target: self, action: #selector(ViewController.hideMenu))
        menuSwipe.direction = .Left
        view.addGestureRecognizer(menuSwipe)
    }
    
    func hideMenu(sender: UIGestureRecognizer){
        if self.sideMenuIsOpen == true{
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.sideMenuWidth.constant -= 200
                self.view.layoutIfNeeded()
                }, completion: nil)
            self.sideMenuIsOpen = false
        }
    }
    
    func toggleSideMenu(){
        if self.sideMenuIsOpen != true {
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.sideMenuWidth.constant += 200
                self.view.layoutIfNeeded()
                }, completion: nil)
            self.sideMenuIsOpen = true
        }else{
            UIView.animateWithDuration(0.5, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
                self.sideMenuWidth.constant -= 200
                self.view.layoutIfNeeded()
                }, completion: nil)
            self.sideMenuIsOpen = false
        }
    }
    
    func setUpHeader(){
        let headerLogo = UIImageView(frame: CGRectMake(0, 0, 40, 40))
        headerLogo.contentMode = .ScaleAspectFit
        headerLogo.image = UIImage(named: "logoCCU_banner")
        
        self.navigationItem.titleView = headerLogo
        self.navigationController?.navigationBar.barStyle = UIBarStyle.Black
        self.navigationController?.navigationBar.tintColor = UIColor.whiteColor()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(named: "fondo_banner"), forBarMetrics: .Default)
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }
    
    func setupImages(){
        let imageSet:[UIImage] = [
            UIImage(named: "inicio01.jpg")!,
            UIImage(named: "inicio02.jpg")!,
            UIImage(named: "inicio03.jpg")!,
            UIImage(named: "inicio04.jpg")!,
        ]
        self.introImage.animationImages = imageSet
        self.introImage.animationDuration = Double(imageSet.count)  * 5.0
        self.introImage.startAnimating()
    }
    
    //User_____
    func isUserFunc() {
        let directorio = NSFileManager.defaultManager()
        do{
            let fileurl = try directorio.URLForDirectory(.DocumentDirectory, inDomain: .UserDomainMask, appropriateForURL: nil, create: true)
            let file = fileurl.URLByAppendingPathComponent("datosUsuario.txt")
            if directorio.fileExistsAtPath(file.path!){
                self.isUser = true
            }else{
                self.isUser = false
            }
        }
        catch{
            self.isUser = false
            let alert = UIAlertController(title: "Error de Lectura", message: "Por favor intente más tarde.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "ok", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func noRegisteredUser(){
        let alert = UIAlertController(title: "¡Regístrese!", message: "Para acceder a todas las funcionalidades de esta aplicación y tener una mejor experiencia de usuario es necesario registrarse. ", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Registrarme", style: UIAlertActionStyle.Default, handler: {action in self.navigationController!.pushViewController(self.storyboard!.instantiateViewControllerWithIdentifier("AccountViewController"), animated: true)}))
        alert.addAction(UIAlertAction(title: "No, Gracias", style: UIAlertActionStyle.Default, handler:nil))
        self.parentViewController!.presentViewController(alert, animated: true, completion: nil)
    }
    
}

