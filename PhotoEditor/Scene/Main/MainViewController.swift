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
        return segmentedControl
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Add photo +", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.tintColor = .black
        button.backgroundColor = .white
        button.layer.cornerRadius = 5
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
    
    @objc func filterControlChanged(_ sender: UISegmentedControl) {
        guard let photoData = mainViewModel.currentPhoto?.data else { return }
        let filterType: FilterType = filterControl.selectedSegmentIndex == 0 ? .original : .bw
        if let filteredData = mainViewModel.applyFilter(to: photoData, filterType: filterType),
           let filteredImage = UIImage(data: filteredData) {
            photoImageView.image = filteredImage
        }
    }
    
    private func showSavePhotoResult(success: Bool, message: String) {
        let alert = UIAlertController(title: success ? "Успех" : "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: Setup UI
    private func setupUI() {
        view.backgroundColor = .systemGray6
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
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(handlePinchGesture(_:)))
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(handleRotationGesture(_:)))

        photoImageView.isUserInteractionEnabled = true
        photoImageView.addGestureRecognizer(panGesture)
        photoImageView.addGestureRecognizer(pinchGesture)
        photoImageView.addGestureRecognizer(rotationGesture)

        panGesture.delegate = self
        pinchGesture.delegate = self
        rotationGesture.delegate = self
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: photoImageView)
        if gesture.state == .changed {
            mainViewModel.updateTranslation(by: (x: Double(translation.x), y: Double(translation.y)))
            gesture.setTranslation(.zero, in: photoImageView)
        }
    }

    @objc private func handlePinchGesture(_ gesture: UIPinchGestureRecognizer) {
        if gesture.state == .changed {
            mainViewModel.updateScale(by: gesture.scale)
            gesture.scale = 1.0
        }
    }

    @objc private func handleRotationGesture(_ gesture: UIRotationGestureRecognizer) {
        if gesture.state == .changed {
            mainViewModel.updateRotation(by: gesture.rotation)
            gesture.rotation = 0
        }
    }
}

// MARK: - Setup Bindings
extension MainViewController {
    private func setupBindings() {
        mainViewModel.currentPhotoDidChange = { [weak self] photoModel in
            guard let self = self, let photoModel = photoModel else { return }
            DispatchQueue.main.async {
                self.photoImageView.image = UIImage(data: photoModel.data)
                self.photoImageView.isHidden = false
                self.enterLabel.isHidden = true
                self.filterControl.selectedSegmentIndex = 0
            }
        }
        
        mainViewModel.transformationDidChange = { [weak self] transform in
            DispatchQueue.main.async {
                self?.photoImageView.transform = transform
            }
        }
    }
}



