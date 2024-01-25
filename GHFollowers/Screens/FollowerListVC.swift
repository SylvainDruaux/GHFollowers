//
//  FollowerListVC.swift
//  GHFollowers
//
//  Created by Sylvain Druaux on 22/08/2023.
//

import UIKit

class FollowerListVC: GFDataLoadingVC {
    enum Section { case main }

    private var username: String!
    private var followers: [Follower] = []
    private var filteredFollowers: [Follower] = []
    private var page: Int = 1
    private var hasMoreFollowers = true
    private var isSearching = false
    private var isLoadingMoreFollowers = false

    private var collectionView: UICollectionView!
    private var dataSource: UICollectionViewDiffableDataSource<Section, Follower>!

    init(username: String) {
        super.init(nibName: nil, bundle: nil)
        self.username = username
        title = username
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViewController()
        configureSearchController()
        configureCollectionView()
        getFollowers(username: username, page: page)
        configureDataSource()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    override func updateContentUnavailableConfiguration(using state: UIContentUnavailableConfigurationState) {
        if followers.isEmpty, !isLoadingMoreFollowers {
            var config = UIContentUnavailableConfiguration.empty()
            config.image = UIImage(systemName: "person.slash")
            config.text = "No followers"
            config.secondaryText = "This user has no followers. Go follow them!"
            contentUnavailableConfiguration = config
            navigationItem.searchController?.searchBar.isHidden = true
        } else if isSearching, filteredFollowers.isEmpty {
            contentUnavailableConfiguration = UIContentUnavailableConfiguration.search()
        } else {
            contentUnavailableConfiguration = nil
            navigationItem.searchController?.searchBar.isHidden = false
        }
    }

    private func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.prefersLargeTitles = true
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.rightBarButtonItem = addButton
    }

    private func configureCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: UIHelper.createThreeColumnLayout(in: view))
        view.addSubview(collectionView)
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.register(FollowerCell.self, forCellWithReuseIdentifier: FollowerCell.reuseID)
    }

    private func configureSearchController() {
        let searchController = UISearchController()
        searchController.searchResultsUpdater = self
        searchController.searchBar.placeholder = "Search for username"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Follower>(collectionView: collectionView) { collectionView, indexPath, follower in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowerCell.reuseID, for: indexPath) as? FollowerCell else {
                return UICollectionViewCell()
            }
            cell.set(follower: follower)
            return cell
        }
    }

    private func updateData(on followers: [Follower]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Follower>()
        snapshot.appendSections([.main])
        snapshot.appendItems(followers)
        DispatchQueue.main.async { self.dataSource.apply(snapshot, animatingDifferences: true) }
    }

    @objc private func addButtonTapped() {
        showLoadingView()

        Task {
            do {
                let user = try await NetworkManager.shared.getUserInfo(for: username)
                addUserToFavorites(user: user)
                dismissLoadingView()
            } catch {
                let errorDescription = (error as? GFError)?.rawValue ?? DefaultAlert.message
                presentGFAlert(title: "Something went wrong", message: errorDescription, buttonTitle: "Ok")
                dismissLoadingView()
            }
        }
    }

    private func addUserToFavorites(user: User) {
        let favorite = Follower(login: user.login, avatarUrl: user.avatarUrl)
        PersistenceManager.updateWith(favorite: favorite, actionType: .add) { [weak self] error in
            guard let self else { return }
            guard let error else {
                DispatchQueue.main.async {
                    self.presentGFAlert(title: "Success!", message: "You have successfully favorited this user 🥳", buttonTitle: "Hooray!")
                }
                return
            }
            DispatchQueue.main.async {
                self.presentGFAlert(title: "Something went wrong", message: error.rawValue, buttonTitle: "Ok")
            }
        }
    }

    private func getFollowers(username: String, page: Int) {
        showLoadingView()
        isLoadingMoreFollowers = true

        Task {
            do {
                let followers = try await NetworkManager.shared.getFollowers(for: username, page: page)
                updateUI(with: followers)
                dismissLoadingView()
                isLoadingMoreFollowers = false
            } catch {
                let errorDescription = (error as? GFError)?.rawValue ?? DefaultAlert.message
                presentGFAlert(title: "Bad stuff Happened", message: errorDescription, buttonTitle: "Ok")
                dismissLoadingView()
                isLoadingMoreFollowers = false
            }
        }
    }

    private func updateUI(with followers: [Follower]) {
        if followers.count < 100 { hasMoreFollowers = false }
        self.followers.append(contentsOf: followers)
        updateData(on: self.followers)
        resetSearchBar()
        setNeedsUpdateContentUnavailableConfiguration()
    }

    private func resetSearchBar() {
        navigationItem.searchController?.searchBar.text = ""
        navigationItem.searchController?.isActive = false
    }
}

extension FollowerListVC: UICollectionViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let height = scrollView.frame.size.height

        if offsetY > contentHeight - height {
            guard hasMoreFollowers, !isLoadingMoreFollowers else { return }
            page += 1
            getFollowers(username: username, page: page)
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let activeArray = isSearching ? filteredFollowers : followers
        let follower = activeArray[indexPath.item]

        let destVC = UserInfoVC()
        destVC.username = follower.login
        destVC.delegate = self
        let navController = UINavigationController(rootViewController: destVC)
        present(navController, animated: true)
    }
}

extension FollowerListVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let filter = searchController.searchBar.text, !filter.isEmpty else {
            filteredFollowers.removeAll()
            updateData(on: followers)
            isSearching = false
            setNeedsUpdateContentUnavailableConfiguration()
            return
        }
        isSearching = true
        filteredFollowers = followers.filter { $0.login.lowercased().contains(filter.lowercased()) }
        updateData(on: filteredFollowers)
        setNeedsUpdateContentUnavailableConfiguration()
    }
}

extension FollowerListVC: UserInfoVCDelegate {
    func didRequestFollowers(for username: String) {
        self.username = username
        title = username
        page = 1

        followers.removeAll()
        filteredFollowers.removeAll()
        resetSearchBar()
        collectionView.scrollToItem(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
        getFollowers(username: username, page: page)
    }
}

#Preview {
    FollowerListVC(username: "SylvainDruaux")
}
