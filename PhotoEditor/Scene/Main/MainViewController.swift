//
//  MainViewController.swift
//  PhotoEditor
//
//  Created by Паша Настусевич on 28.11.24.
//

import UIKit

final class MainViewController: UIViewController {
    
    private var mainViewModel: MainViewModelProtocol!
    
    private var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderColor = UIColor.yellow.cgColor
        imageView.layer.borderWidth = 2
        imageView.isHidden = true
        return imageView
    }()
    
    private var filterControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Original", "BW"])
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.shadowColor = UIColor.black.cgColor
        segmentedControl.layer.shadowOpacity = 0.3
        segmentedControl.layer.shadowOffset = .zero
        
        return segmentedControl
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add Photo +", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOpacity = 0.3
        button.layer.shadowOffset = .zero
        
        return button
    }()
    
    private let enterLabel: UILabel = {
        let label = UILabel()
        label.text = "Выберите фото для редактирования. Нажмите кнопку Add Photo"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        return label
    }()
    
    init(mainViewModel: MainViewModelProtocol) {
        self.mainViewModel = mainViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setupUI()
        setupBindings()
        setupGestures()
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        filterControl.addTarget(self, action: #selector(filterControlChanged(_:)), for: .valueChanged)

    }
    
    @objc func saveButtonTapped() {
        mainViewModel.savePhoto { [weak self] success, message in
            DispatchQueue.main.async {
                self?.showSavePhotoResult(success: success, message: message)
            }
        }
    }
    
    @objc func addButtonTapped() {
        mainViewModel.pickPhoto()
    }
    
    private func showSavePhotoResult(success: Bool, message: String) {
        let alert = UIAlertController(title: success ? "Успех" : "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @objc func filterControlChanged(_ sender: UISegmentedControl) {
        guard let photo = mainViewModel.currentPhoto?.image else { return }
        let filterType: FilterType = filterControl.selectedSegmentIndex == 0 ? .original : .bw
        let filteredImage = mainViewModel.applyFilter(to: photo, filterType: filterType)
        photoImageView.image = filteredImage
    }
    
    private func setupUI() {
        view.addSubview(photoImageView)
        view.addSubview(filterControl)
        view.addSubview(addButton)
        view.addSubview(enterLabel)
        
        layoutConstraints()
        setupNavigationBar()
    }
    
    private func setupNavigationBar() {
        title = "Photo Editor"
        let saveButton = UIBarButtonItem(title: "Save 💾", style: .plain, target: self, action: #selector(saveButtonTapped))
     
        navigationItem.rightBarButtonItem = saveButton
        
    }
    
    private func layoutConstraints() {
        photoImageView.translatesAutoresizingMaskIntoConstraints = false
        filterControl.translatesAutoresizingMaskIntoConstraints = false
        addButton.translatesAutoresizingMaskIntoConstraints = false
        enterLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate(
            [
            photoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            photoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 40),
            photoImageView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85),
            photoImageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            filterControl.topAnchor.constraint(equalTo: view.topAnchor, constant: 120),
            filterControl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            filterControl.widthAnchor.constraint(equalToConstant: 150),
            filterControl.heightAnchor.constraint(equalTo: addButton.heightAnchor),
            
            addButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addButton.centerYAnchor.constraint(equalTo: filterControl.centerYAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 150),
            
            enterLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            enterLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            enterLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8),
            enterLabel.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.8)
        ]
        )
    }
}

// MARK: - Setup Gestures
extension MainViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    private func setupGestures() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(panGesture)
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        photoImageView.addGestureRecognizer(pinchGesture)
        
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))
        photoImageView.addGestureRecognizer(rotationGesture)
        
        panGesture.delegate = self
        pinchGesture.delegate = self
        rotationGesture.delegate = self
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        guard let gestureView = gesture.view else { return }
        
        let translation = gesture.translation(in: gestureView)
        
        switch gesture.state {
        case .changed:
            gestureView.center = CGPoint(
                x: gestureView.center.x + translation.x,
                y: gestureView.center.y + translation.y
                )
            gesture.setTranslation(.zero, in: view)
        default:
            break
        }
    }

    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let gestureView = gesture.view else { return }
        
        switch gesture.state {
        case .changed:
            gestureView.transform = gestureView.transform.scaledBy(x: gesture.scale, y: gesture.scale)
            gesture.scale = 1.0
        default:
            break
        }
    }
    
    @objc private func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        guard let gestureView = gesture.view else { return }
        switch gesture.state {
        case .changed:
            gestureView.transform = gestureView.transform.rotated(by: gesture.rotation)
            gesture.rotation = 0
        default:
            break
        }
    }
}

// MARK: - Setup Bindings
extension MainViewController {
    private func setupBindings() {
        mainViewModel.currentPhotoDidChange = { [weak self] photoModel in
            guard let self = self, let photoModel = photoModel else { return }
            DispatchQueue.main.async {
                self.photoImageView.image = photoModel.image
                self.photoImageView.isHidden = false
                self.enterLabel.isHidden = true
                self.filterControl.selectedSegmentIndex = 0
            }
        }
    }
}



